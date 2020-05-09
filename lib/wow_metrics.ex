defmodule WowMetrics do
  @http_adapter Application.get_env(:wow_metrics, :http_adapter)

  def oauth_token() do
    client_id = Application.fetch_env!(:wow_metrics, :client_id)
    client_secret = Application.fetch_env!(:wow_metrics, :client_secret)
    url = Application.fetch_env!(:wow_metrics, :oauth_url)

    access_token = "#{client_id}:#{client_secret}" |> Base.encode64()
    headers = ["Authorization": "Basic #{access_token}"]

    case @http_adapter.get!(url, headers) do
      %HTTPoison.Response{status_code: 200, body: body} ->
        %{"access_token" => access_token} = Jason.decode!(body)
        {:ok, access_token, Jason.decode!(body)}
      %HTTPoison.Response{body: body} ->
        {:error, nil, Jason.decode!(body)}
    end
  end

end
