defmodule PVAData.PVAWebsite.DivisionParser do
  import Meeseeks.CSS

  alias PVAData.PVAWebsite.DateUtils
  alias PVAData.{Division, Match, Team, Standing}

  def get_division(division_html) do
    case Meeseeks.parse(division_html) do
      {:error, _} ->
        {:error, "could not parse html"}

      document ->
        with {:ok, division} <- build_division(document),
             {:ok, division} <- add_teams_and_standings(division, document),
             {:ok, division} <- add_matches(division, document),
             {:ok, division} <- update_standings_and_ranks(division) do
          {:ok, division}
        else
          error -> {:error, error}
        end
    end
  end

  defp build_division(document) do
    document
    |> Meeseeks.fetch_one(css("#PageSubTitleSpan"))
    |> case do
      {:ok, division_name_span} ->
        {:ok, Division.build(Meeseeks.text(division_name_span))}

      {:error, _} ->
        {:error, "could not find division name"}
    end
  end

  defp add_teams_and_standings(division, document) do
    document
    |> Meeseeks.fetch_all(css("div[id$=\"standingsGrid\"] tbody tr"))
    |> case do
      {:ok, team_rows} ->
        teams =
          Enum.map(team_rows, fn team_row ->
            # if this fails, we're letting it crash because something changed on the pva site
            [_place, name, _w, _l, _t, _gb, _gp, _pct, _str, coach] =
              Meeseeks.all(team_row, css("td"))
              |> Enum.map(&Meeseeks.text/1)

            %{Team.build(division, name) | contact: coach}
          end)

        standings =
          teams
          |> Enum.map(fn team -> Standing.new(team_id: team.id, division_id: division.id) end)

        division =
          division
          |> Map.put(:teams, teams)
          |> Map.put(:standings, standings)

        {:ok, division}

      {:error, _} ->
        {:error, "could not get teams and standings"}
    end
  end

  defp add_matches(division, document) do
    with {:ok, regular_season_container} <-
           Meeseeks.fetch_one(document, css(".standingResultsSchedulesTable")),
         {:ok, regular_season_rows} <-
           Meeseeks.fetch_all(regular_season_container, css("tr.rgRow, tr.rgAltRow")) do
      regular_season_matches = build_matches(division, regular_season_rows)
      playoff_matches = get_playoff_matches(division, document)
      matches = regular_season_matches ++ playoff_matches

      # note that sheduled matches also includes completed matches that just lack scores
      # these can be filtered out on the front end based on the date in the client timezone
      {completed_matches, scheduled_matches} =
        matches
        |> Enum.split_with(&Match.has_results?/1)

      division =
        division
        |> Map.put(:scheduled_matches, scheduled_matches)
        |> Map.put(:completed_matches, completed_matches)

      {:ok, division}
    else
      {:error, _} -> {:error, "could not get matches"}
    end
  end

  def is_schedule_conflict?(td) do
    case Meeseeks.fetch_one(td, css(".resultsCommentsPanel span:nth-child(2)")) do
      {:ok, comment_span} ->
        Meeseeks.text(comment_span)
        |> String.downcase()
        |> String.contains?("schedule conflict")

      {:error, _} ->
        false
    end
  end

  def get_playoff_matches(division, document) do
    with {:ok, playoffs_container} <-
           Meeseeks.fetch_one(document, css("table[id*=PlayoffGrid]")),
         {:ok, playoffs_rows} <-
           Meeseeks.fetch_all(playoffs_container, css("tr.rgRow, tr.rgAltRow")) do
      build_matches(division, playoffs_rows)
      |> Enum.filter(fn match ->
        Enum.any?(division.teams, &(&1.id == match.home_team_id)) &&
          Enum.any?(division.teams, &(&1.id == match.visiting_team_id))
      end)
    else
      _ ->
        []
    end
  end

  def build_matches(division, rows) do
    rows
    |> Enum.reduce([], fn row, matches ->
      case Meeseeks.fetch_all(row, css("td")) do
        {:ok, match_row = [_, _, _, _, _]} ->
          case build_match(division, match_row) do
            {:ok, match} -> [match | matches]
            _ -> matches
          end

        {:ok, [date, time, _playoffs_game_number, home, away, location]} ->
          case build_match(division, [date, time, home, away, location]) do
            {:ok, match} -> [match | matches]
            _ -> matches
          end

        {:ok, [single_td]} ->
          [latest_match | other_matches] = matches

          if is_schedule_conflict?(single_td) do
            other_matches
          else
            updated_match =
              latest_match
              |> add_ref(single_td)
              |> add_scores(single_td)

            [updated_match | other_matches]
          end

        {:error, _} ->
          # neither a match row nor a results row, so we ignore it
          matches
      end
    end)
    |> Enum.reverse()
  end

  defp build_match(division, match_row) do
    [date_td, time_td, home_td, visitor_td, location_td] = match_row

    date = DateUtils.parse_date(Meeseeks.text(date_td))
    time = DateUtils.parse_time(Meeseeks.text(time_td))

    [[home, home_score], [visitor, visitor_score]] =
      [home_td, visitor_td]
      |> Enum.map(fn td ->
        td
        |> parse_team_td()
        |> then(fn [name, score] -> [Team.build(division, name), score] end)
      end)

    forfeited_team_id =
      case [home_score, visitor_score] do
        [_, "L"] -> visitor.id
        ["L", _] -> home.id
        _ -> nil
      end

    location_link = location_td |> Meeseeks.one(css("a"))

    location_url =
      location_link
      |> Meeseeks.attr("href")
      |> then(fn
        nil -> nil
        url -> String.replace(url, "http:", "https:")
      end)

    location_name = location_link |> Meeseeks.one(css("span")) |> Meeseeks.text()

    if is_nil(date) || is_nil(time) do
      {:error, "invalid match, probably a bye"}
    else
      {:ok,
       Match.new(
         date: date,
         time: time,
         division_id: division.id,
         home_team_id: home.id,
         visiting_team_id: visitor.id,
         location_name: location_name,
         location_url: location_url,
         forfeited_team_id: forfeited_team_id
       )}
    end
  end

  defp parse_team_td(td) do
    case Meeseeks.fetch_all(td, css("div span")) do
      {:error, _} ->
        [nil, nil]

      {:ok, [name_span, score_span]} ->
        name_text = Meeseeks.text(name_span) |> String.trim()
        score_text = Meeseeks.text(score_span) |> String.trim()

        case score_text do
          "" -> [name_text, nil]
          _ -> [name_text, score_text]
        end

      {:ok, [name_span | _]} ->
        [Meeseeks.text(name_span) |> String.trim(), nil]
    end
  end

  defp add_ref(match, td) do
    case Meeseeks.fetch_one(td, css(".resultsCommentsPanel span:nth-child(2)")) do
      {:ok, ref_span} ->
        case get_ref(Meeseeks.text(ref_span)) do
          nil -> match
          ref -> %{match | ref: ref}
        end

      {:error, _} ->
        # not a results row, so we ignore it
        match
    end
  end

  defp get_ref(results_text) do
    # "Officials: Jane Doe (Volleyball)" is the typical format of the span text
    # So we get the text after "Officials: " and before an optional opening paren
    case Regex.run(~r/^Officials:\s+([^(]+)/, results_text) do
      [_, name] -> String.trim(name)
      _ -> nil
    end
  end

  defp add_scores(%Match{} = match, td) do
    case Meeseeks.fetch_one(td, css(".resultsMultiScorePanel span:nth-child(2)")) do
      {:ok, results_span} ->
        scores = get_scores(Meeseeks.text(results_span))
        Match.add_set_results(match, scores)

      {:error, _} ->
        # not a results row, so we ignore it
        match
    end
  end

  defp get_scores(results_text) do
    scores_regex = ~r/\d+-\d+/

    for match <- Regex.scan(scores_regex, results_text) do
      set_results_string = hd(match)
      [home_score, visitor_score] = String.split(set_results_string, "-")
      {String.to_integer(home_score), String.to_integer(visitor_score)}
    end
  end

  defp update_standings_and_ranks(division) do
    standings =
      division.standings
      |> Enum.map(fn standing = %Standing{team_id: team_id} ->
        results =
          division.completed_matches
          |> Enum.filter(fn match ->
            match.home_team_id == team_id || match.visiting_team_id == team_id
          end)
          |> Enum.map(fn match -> Match.result(match, team_id) end)
          |> Enum.frequencies()

        wins = Map.get(results, :win, 0)
        losses = Map.get(results, :loss, 0)
        played = wins + losses
        winning_percentage = if played == 0, do: 0, else: Float.round(wins / played * 100, 3)

        point_differentials =
          Division.completed_matches_involving_team(division, team_id)
          |> Enum.map(fn match -> Match.point_differential(match, team_id) end)

        average_point_differential =
          if Enum.empty?(point_differentials) do
            0.0
          else
            Float.round(Enum.sum(point_differentials) / Enum.count(point_differentials), 3)
          end

        standing
        |> Map.put(:wins, Map.get(results, :win, 0))
        |> Map.put(:losses, Map.get(results, :loss, 0))
        |> Map.put(:winning_percentage, winning_percentage)
        |> Map.put(:average_point_differential, average_point_differential)
      end)

    division =
      division
      |> Map.put(:standings, standings)
      |> Division.add_ranks()

    {:ok, division}
  end
end
