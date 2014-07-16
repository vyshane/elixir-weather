defmodule Weather.Location do

  @moduledoc "Handle fetching of location data from the Google Maps service."

  alias HTTPotion.Response

  @user_agent ["User-agent": "Elixir Weather"]
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
                |> HTTPotion.get

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
    [best_match | _] = results

    [_address_components,
      {"formatted_address", location_name},
      {"geometry", geometry},
      _types
    ] = best_match

    [_bounds,
      {"location", [{"lat", latitude}, {"lng", longitude}]},
      _location_type,
      _viewport
    ] = geometry

    location = %Weather.Location{
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