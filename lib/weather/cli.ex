defmodule Weather.CLI do
  @moduledoc """
  Handle command line parsing and dispatch to the functions that will fetch
  and display the weather for the given location.
  """

  use Pipe
  alias Weather.Location
  alias Weather.Weather

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
    IO.puts "Usage: weather <location>"
    System.halt(0)
  end

  def process(location_name) do
    pipe_while(
      &no_error/1,

      Location.fetch(location_name)
      |> print_location
      |> fetch_weather
      |> print_weather
    )
  end

  def fetch_weather({:ok, location}) do
    Weather.fetch(location.latitude, location.longitude)
  end

  defp no_error({:ok, _}), do: true
  defp no_error({:error, value}) do
    IO.puts value
    System.halt(2)
  end

  def print_location({status, location}) do
    IO.puts "\nWeather for #{location.name}"
    {status, location}
  end

  def print_weather({status, {current, forecast}}) do
    IO.puts "Currently: #{current.temperature}°, " <>
      "#{current.humidity}% humidity, #{current.summary}\n"

    Enum.map forecast, fn (day) ->
      {y, m, d} = day.date

      IO.puts "#{d}/#{m}/#{y}: " <>
        "#{day.max_temperature}°|" <>
        "#{day.min_temperature}°, " <>
        "#{current.humidity}% humidity, " <>
        "#{day.summary}."
    end

    IO.puts ""
    {status, "done"}
  end
end
