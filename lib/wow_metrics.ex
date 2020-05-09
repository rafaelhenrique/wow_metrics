defmodule WowMetrics do
  @moduledoc """
    Provides methods for getting metrics from World of Warcraft API
  """
  @http_adapter Application.get_env(:wow_metrics, :http_adapter)


  @doc """
    Returns a tuple with access token or with error.

  ## Examples

      iex> WowMetrics.oauth_token
      {:ok, "aSDFasdf6asdf123asdfasdfASDFqwerty",
       %{
         "access_token" => "aSDFasdf6asdf123asdfasdfASDFqwerty",
         "expires_in" => 86399,
         "token_type" => "bearer"
       }}
  """
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
