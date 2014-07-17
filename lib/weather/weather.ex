defmodule Weather.Weather.Current do

  defstruct summary: "",
    temperature: nil,
    humidity: nil

end

defmodule Weather.Weather.Forecast do

  defstruct summary: "",
    date: nil,
    min_temperature: nil,
    max_temperature: nil,
    humidity: nil

end

defmodule Weather.Weather do

  @moduledoc """
  Handle fetching of weather forecast data from the Forecast.io web service.
  """

  alias HTTPotion.Response
  alias Weather.Weather

  @user_agent Application.get_env :weather, :user_agent
  @forecast_api_url Application.get_env :weather, :forecast_io_web_service_url
  @forecast_io_api_key Application.get_env :weather, :forecast_io_api_key

  @doc """
  Expects the latitude and longitude of the location that we want to use to
  query the web service.

  Returns {:ok, %Weather.Forecast} or {:error, error_message}
  """
  def fetch(latitude, longitude) do
    _fetch_from_web_service(latitude, longitude)
      |> _parse_forecast
  end

  defp _fetch_from_web_service(latitude, longitude) do
    response = _location_url(latitude, longitude)
      |> URI.encode
      |> HTTPotion.get @user_agent

    return_code = if Response.success?(response), do: :ok, else: :error
    {return_code, response.body}
  end

  defp _location_url(latitude, longitude) do
    "#{@forecast_api_url}#{@forecast_io_api_key}/" <>
    "#{latitude},#{longitude}/?units=si&lang=en"
  end

  defp _parse_forecast({:ok, body}) do
    discard_key = fn {_, list} -> list end
    data = Jsonex.decode body

    current_summary = data
      |> List.keyfind("currently", 0, nil)
      |> discard_key.()
      |> List.keyfind("summary", 0, nil)
      |> discard_key.()

    current_data = data
      |> List.keyfind("currently", 0, nil)
      |> discard_key.()

    current_temperature = current_data
      |> List.keyfind("temperature", 0, nil)
      |> discard_key.()

    current_humidity = current_data
      |> List.keyfind("humidity", 0, nil)
      |> discard_key.()

    current_weather = %Weather.Current{
      summary: current_summary,
      temperature: current_temperature,
      humidity: current_humidity
    }

    forecast_data = data
      |> List.keyfind("daily", 0, nil)
      |> discard_key.()

    forecast_summary = forecast_data
      |> List.keyfind("summary", 0, nil)
      |> discard_key.()

    parse_forecast = fn(day_data) ->
      day_summary = day_data
        |> List.keyfind("summary", 0, nil)
        |> discard_key.()
        |> String.rstrip ?.

      day_timestamp = day_data
        |> List.keyfind("time", 0, nil)
        |> discard_key.()

      base_date = :calendar.datetime_to_gregorian_seconds({{1970,1,1},{0,0,0}})
      {day_date, _time} = :calendar.gregorian_seconds_to_datetime(
        base_date + day_timestamp)

      day_max_temperature = day_data
        |> List.keyfind("temperatureMax", 0, nil)
        |> discard_key.()

      day_min_temperature = day_data
        |> List.keyfind("temperatureMin", 0, nil)
        |> discard_key.()

      day_humidity = day_data
        |> List.keyfind("humidity", 0, nil)
        |> discard_key.()

      %Weather.Forecast{
        summary: day_summary,
        date: day_date,
        min_temperature: day_min_temperature,
        max_temperature: day_max_temperature,
        humidity: day_humidity
      }
    end

    forecast = forecast_data
      |> List.keyfind("data", 0, nil)
      |> discard_key.()
      |> Enum.drop(1)
      |> Enum.map(&(parse_forecast.(&1)))

    {:ok, {current_weather, forecast}}
  end

  defp _parse_forecast({:error, _}) do
    {:error, "Unable to fetch weather forecast"}
  end

end
