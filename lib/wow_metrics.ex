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
    headers = [Authorization: "Basic #{access_token}"]

    case @http_adapter.get!(url, headers) do
      %HTTPoison.Response{status_code: 200, body: body} ->
        %{"access_token" => access_token} = Jason.decode!(body)
        {:ok, access_token, Jason.decode!(body)}

      %HTTPoison.Response{body: body} ->
        {:error, nil, Jason.decode!(body)}
    end
  end

  def statistics(
        {:ok, access_token, _},
        %{
          region: region,
          realm: realm,
          character_name: character_name,
          namespace: namespace,
          locale: locale
        }
      ) do
    # TODO: Remove this url from here and move to config
    url =
      "https://#{region}.api.blizzard.com/profile/wow/character/#{realm}/#{character_name}/statistics?namespace=#{
        namespace
      }&locale=#{locale}&access_token=#{access_token}"

    headers = [Authorization: "Bearer #{access_token}"]

    case @http_adapter.get!(url, headers) do
      %HTTPoison.Response{status_code: 200, body: body} ->
        {:ok, Jason.decode!(body)}

      %HTTPoison.Response{body: body} ->
        {:error, Jason.decode!(body)}
    end
  end

  def players_statistics(token, players) do
    Enum.map(players, fn player ->
      token
      |> WowMetrics.statistics(player)
      |> player_to_map
    end)
  end

  defp player_to_map({:ok, body}) do
    %{"corruption" => corruption} = body
    %{"effective_corruption" => effective_corruption} = corruption
    %{"character" => character} = body
    %{"name" => name} = character

    %WowMetrics.Player{name: name, effective_corruption: effective_corruption}
  end

  defp player_to_map({:error, body}) do
    body
  end

  def calculate_effective_corruption_mean(players) do
    corruption_total =
      Enum.reduce(players, 0, fn %WowMetrics.Player{effective_corruption: effective_corruption},
                                 acc ->
        effective_corruption + acc
      end)

    corruption_total / length(players)
  end

  def main() do
    WowMetrics.oauth_token()
    |> players_statistics([
      %{
        locale: "en_US",
        region: "us",
        namespace: "profile-us",
        realm: "tichondrius",
        character_name: "nikolei"
      },
      %{
        locale: "en_US",
        region: "us",
        namespace: "profile-us",
        realm: "illidan",
        character_name: "junkratxd"
      },
      %{
        locale: "en_US",
        region: "us",
        namespace: "profile-us",
        realm: "area-52",
        character_name: "ohnut"
      },
      %{
        locale: "en_US",
        region: "eu",
        namespace: "profile-eu",
        realm: "ysondre",
        character_name: "kreay"
      },
      %{
        locale: "en_US",
        region: "eu",
        namespace: "profile-eu",
        realm: "tarren-mill",
        character_name: "álanis"
      },
      %{
        locale: "en_US",
        region: "eu",
        namespace: "profile-eu",
        realm: "hyjal",
        character_name: "lekträh"
      },
      %{
        locale: "en_US",
        region: "eu",
        namespace: "profile-eu",
        realm: "howling-fjord",
        character_name: "ловайкъю"
      },
      %{
        locale: "en_US",
        region: "eu",
        namespace: "profile-eu",
        realm: "blackhand",
        character_name: "seliandrá"
      },
      %{
        locale: "en_US",
        region: "eu",
        namespace: "profile-eu",
        realm: "twisting-nether",
        character_name: "trxë"
      }
    ])
    |> calculate_effective_corruption_mean
  end
end
