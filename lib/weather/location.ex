defmodule Weather.Location do

  @moduledoc "Handle fetching of location data from the Google Maps service."

  alias HTTPotion.Response
  alias Weather.Location

  @user_agent Application.get_env :weather, :user_agent
  @location_api_url Application.get_env :weather, :google_maps_web_service_url

  defstruct name: "", latitude: nil, longitude: nil

  @doc """
  location_name is the string to be used to query the web service.

  Returns {:ok, %Weather.Location} or {:error, error_message}
  """
  def fetch(location_name) do
    _fetch_from_web_service(location_name)
      |> _parse_location
  end

  defp _fetch_from_web_service(location_name) do
    response = _location_url(location_name)
      |> URI.encode
      |> HTTPotion.get @user_agent

    return_code = if Response.success?(response), do: :ok, else: :error
    {return_code, response.body}
  end

  defp _location_url(location_name) do
    "#{@location_api_url}?address=#{location_name}"
  end

  defp _parse_location({:ok, body}) do
    body
      |> Jsonex.decode
      |> _parse_location_body
  end

  defp _parse_location({:error, _}) do
    {:error, "Unable to fetch location"}
  end

  defp _parse_location_body([{"results", results}, {"status", "OK"}]) do
    discard_key = fn {_, list} -> list end
    [best_match | _] = results

    location_name = best_match
      |> List.keyfind("formatted_address", 0, nil)
      |> discard_key.()

    geometry_location = best_match
      |> List.keyfind("geometry", 0, nil)
      |> discard_key.()
      |> List.keyfind("location", 0, nil)
      |> discard_key.()

    latitude = geometry_location
      |> List.keyfind("lat", 0, nil)
      |> discard_key.()

    longitude = geometry_location
      |> List.keyfind("lng", 0, nil)
      |> discard_key.()

    location = %Location{
      name: location_name,
      latitude: latitude,
      longitude: longitude
    }

    {:ok, location}
  end

  defp _parse_location_body([_results, {"status", "ZERO_RESULTS"}]) do
    {:error, "Could not find the location."}
  end

  defp _parse_location_body([_results, {"status", _not_ok}]) do
    {:error, "Unable to parse fetched location data."}
  end

end