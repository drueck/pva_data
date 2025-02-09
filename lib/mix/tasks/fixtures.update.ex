defmodule Mix.Tasks.Fixtures.Update do
  @moduledoc """
  Adds or replaces test fixture files from the current PVA website.

  Usage: `mix fixtures.update [subdir]`

  Deletes any existing fixtures in the target directory
  (test/fixtures/["default"|subdir]) and creates new fixture files from the
  current contents of the relevant pages on the PVA website.

  Be sure to back up your current fixture files if needed before running this!
  """

  @shortdoc "Updates test fixtures"

  @website_path "https://portlandvolleyball.org"
  @fixture_path "test/fixtures"

  use Mix.Task

  @impl Mix.Task
  def run([subdir | _rest]) do
    do_run("#{@fixture_path}/#{subdir}")
  end

  def run([]) do
    do_run("#{@fixture_path}/default")
  end

  def do_run(fixture_path) do
    HTTPoison.start()

    path = Path.expand(fixture_path)

    with :ok <- ensure_directory_exists(path),
         :ok <- ensure_directory_empty(path),
         :ok <- save_schedules_page(path),
         {:ok, division_urls} <- PVAData.PVAWebsite.Client.get_division_urls(),
         :ok <- save_division_pages(path, division_urls) do
      :ok
    else
      {:error, reason} -> IO.puts("Fixture update cancelled: #{reason}")
    end
  end

  defp ensure_directory_exists(path) do
    case File.mkdir_p(path) do
      :ok -> :ok
      error_tuple -> error_tuple
    end
  end

  defp ensure_directory_empty(path) do
    case File.ls(path) do
      {:ok, []} ->
        :ok

      {:ok, files} ->
        IO.puts("#{path} is not empty. Do you want to delete its contents? [Y/N]")

        IO.gets("> ")
        |> String.trim()
        |> String.downcase()
        |> case do
          "y" ->
            Enum.each(files, fn file ->
              File.rm_rf(Path.join(path, file))
            end)

            :ok

          _ ->
            {:error, "You chose not to delete the existing files"}
        end

      error_tuple ->
        error_tuple
    end
  end

  defp save_schedules_page(path) do
    url = "#{@website_path}/schedules"

    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url, [], follow_redirect: true),
         :ok <- File.write(Path.join(path, "schedules"), body) do
      :ok
    else
      {:error, error = %HTTPoison.Error{}} ->
        {:error, Exception.message(error)}

      error_tuple ->
        error_tuple
    end
  end

  defp save_division_pages(path, division_urls) do
    division_urls
    |> Enum.map(fn page_path ->
      {page_path, HTTPoison.get("#{@website_path}/#{page_path}", [], follow_redirect: true)}
    end)
    |> Enum.map(fn
      {_, {:error, reason}} ->
        {:error, reason}

      {page_path, {:ok, %HTTPoison.Response{body: body}}} ->
        file_path = Path.join(path, page_path)

        with :ok <- File.mkdir_p(Path.dirname(file_path)),
             :ok <- File.write(file_path, body) do
          :ok
        else
          error_tuple -> error_tuple
        end
    end)
    |> then(fn results ->
      case Enum.all?(results, &(&1 == :ok)) do
        true -> :ok
        false -> {:error, "Failed to fetch or write one or more pages"}
      end
    end)
  end
end
