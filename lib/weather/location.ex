defmodule Weather.Location do

  alias HTTPotion.Response

  @user_agent ["User-agent": "Elixir Weather"]
  @location_api_url Application.get_env :weather, :google_maps_web_service_url

  def fetch(location_name) do
    response = location_url(location_name)
                |> URI.encode
                |> HTTPotion.get

    return_code = if Response.success?(response), do: :ok, else: :error
    {return_code, response.body}
  end

  def location_url(location_name) do
    "#{@location_api_url}?address=#{location_name}"
  end

end