# PVAData

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `pva_data` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pva_data, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/pva_data](https://hexdocs.pm/pva_data).

Use cases:

# division-wide info
- /divisions - get a list of the divisions with their names and slugs
- /divisions/:division-slug/teams - show a list of teams for that division
- /divisions/:division-slug/standings - show the standings for that division
- /divisions/:division-slug/schedules - show the schedules for that division
- /divisions/:division-slug/scores - show the scores for that division

# per-team info
- /divisions/:division-slug/teams/:team-slug - dashboard for the team with links to team scores, schedules, standings (or inline info?)
- /divisions/:division-slug/teams/:team-slug/scores - scores just for that team's matches from that division
- /divisions/:division-slug/teams/:team-slug/schedules - upcoming matches for that team

%{
  divisions: %{
    division"-1-slug": %Division{
      name: name,
      slug: slug,
      teams: [
        %Team{},
      ],
      standings: [
        %Standing{},
      ],
      scores: [
        %Match{}, 
      ],
      schedules: [
        %Match{}
      ]
    }
  }
}
