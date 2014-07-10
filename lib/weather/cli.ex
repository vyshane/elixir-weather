defmodule Weather.CLI do

  @moduledoc """
  Handle command line parsing and dispatch to the functions that will fetch
  and display the weather for the given location.
  """

  def main(argv) do
    argv 
      |> parse_args 
      |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help. Otherwise argv is the
  location name for which we want to fetch the weather.

  Returns the location name as a string, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                     aliases: [h: :help])
    case parse do
      {[help: true], _, _} -> :help
      {_, location_name, _} -> location_name
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    Usage: weather <location>
    """
    System.halt(0)
  end

  def process(location_name) do
    Weather.Location.fetch(location_name)
      |> IO.puts
  end

end
