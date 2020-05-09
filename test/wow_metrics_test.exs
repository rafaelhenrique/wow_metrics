defmodule WowMetricsTest do
  use ExUnit.Case
  # doctest WowMetrics
  alias Http.Mock
  import Mox

  setup :verify_on_exit!

  describe "oauth_token" do
    test "oauth_token with correct credentials needs be return a valid bearer token" do
      expect(Mock, :get!, fn _, _ ->
        %HTTPoison.Response{
          status_code: 200,
          body: "{\"access_token\":\"USvegdNo6SNVonaLG28O3tSYYVXfMu1hG8\",\"token_type\":\"bearer\",\"expires_in\":86399}"
        }
      end)

      assert WowMetrics.oauth_token() == {
        :ok,
        "USvegdNo6SNVonaLG28O3tSYYVXfMu1hG8",
        %{
          "access_token" => "USvegdNo6SNVonaLG28O3tSYYVXfMu1hG8",
          "expires_in" => 86_399,
          "token_type" => "bearer"
        }
      }
    end

    test "oauth_token with invalid credentials needs be return a error" do
      expect(Mock, :get!, fn _, _ ->
        %HTTPoison.Response{status_code: 401, body: "{\"error\":\"unauthorized\",\"error_description\":\"Bad credentials\"}"}
      end)

      assert WowMetrics.oauth_token() == {
        :error,
        nil,
        %{
          "error" => "unauthorized",
          "error_description" => "Bad credentials"
        }
      }
    end
  end

  describe "statistics" do
    @player %{locale: "en_US", region: "us", namespace: "profile-us", realm: "goldrinn", character_name: "faölin"}
    @token {
      :ok,
      "USvegdNo6SNVonaLG28O3tSYYVXfMu1hG8",
      %{
        "access_token" => "USvegdNo6SNVonaLG28O3tSYYVXfMu1hG8",
        "expires_in" => 86_399,
        "token_type" => "bearer"
      }
    }

    test "statistics with correct credentials needs be return a valid statistic for a player" do
      expect(Mock, :get!, fn _, _ ->
        %HTTPoison.Response{
          status_code: 200,
          body: "{\"corruption\":{\"corruption\":125.0,\"corruption_resistance\":81.0,\"effective_corruption\":44.0}}"
        }
      end)

      assert WowMetrics.statistics(@token, @player) == {
        :ok,
        %{"corruption" => %{"corruption" => 125.0, "corruption_resistance" => 81.0, "effective_corruption" => 44.0}}
      }
    end

    test "statistics with invalid credentials needs be return a error" do
      expect(Mock, :get!, fn _, _ ->
        %HTTPoison.Response{status_code: 401, body: "{\"error\":\"unauthorized\",\"error_description\":\"Bad credentials\"}"}
      end)

      assert WowMetrics.statistics(@token, @player) == {
        :error,
        %{
          "error" => "unauthorized",
          "error_description" => "Bad credentials"
        }
      }
    end
  end

  describe "players_statistics" do
    @players [
      %{locale: "en_US", region: "us", namespace: "profile-us", realm: "tichondrius", character_name: "nikolei"},
      %{locale: "en_US", region: "us", namespace: "profile-us", realm: "illidan", character_name: "junkratxd"},
      %{locale: "en_US", region: "us", namespace: "profile-us", realm: "goldrinn", character_name: "faölin"}
    ]
    @token {
      :ok,
      "USvegdNo6SNVonaLG28O3tSYYVXfMu1hG8",
      %{
        "access_token" => "USvegdNo6SNVonaLG28O3tSYYVXfMu1hG8",
        "expires_in" => 86_399,
        "token_type" => "bearer"
      }
    }

    test "players_statistics with correct credentials needs be return a valid list with WowMetrics.Player" do
      expect(Mock, :get!, fn _, _ ->
        %HTTPoison.Response{
          status_code: 200,
          body: "{\"character\":{\"name\":\"Nikolei\"},\"corruption\":{\"corruption\":123.0,\"corruption_resistance\":82.0,\"effective_corruption\":123.0}}"
        }
      end)
      expect(Mock, :get!, fn _, _ ->
        %HTTPoison.Response{
          status_code: 200,
          body: "{\"character\":{\"name\":\"Junkratxd\"},\"corruption\":{\"corruption\":124.0,\"corruption_resistance\":87.0,\"effective_corruption\":456.0}}"
        }
      end)
      expect(Mock, :get!, fn _, _ ->
        %HTTPoison.Response{
          status_code: 200,
          body: "{\"character\":{\"name\":\"Faölin\"},\"corruption\":{\"corruption\":127.0,\"corruption_resistance\":85.0,\"effective_corruption\":789.0}}"
        }
      end)

      assert WowMetrics.players_statistics(@token, @players) == [
        %WowMetrics.Player{effective_corruption: 123.0, name: "Nikolei"},
        %WowMetrics.Player{effective_corruption: 456.0, name: "Junkratxd"},
        %WowMetrics.Player{effective_corruption: 789.0, name: "Faölin"}
      ]
    end

    test "players_statistics with correct credentials return partial valid list with WowMetrics.Player" do
      expect(Mock, :get!, fn _, _ ->
        %HTTPoison.Response{
          status_code: 200,
          body: "{\"character\":{\"name\":\"Nikolei\"},\"corruption\":{\"corruption\":123.0,\"corruption_resistance\":82.0,\"effective_corruption\":123.0}}"
        }
      end)
      expect(Mock, :get!, fn _, _ ->
        %HTTPoison.Response{
          status_code: 403,
          body: "{\"code\":403,\"type\":\"BLZWEBAPI00000403\",\"detail\":\"Forbidden\"}"
        }
      end)
      expect(Mock, :get!, fn _, _ ->
        %HTTPoison.Response{
          status_code: 200,
          body: "{\"character\":{\"name\":\"Faölin\"},\"corruption\":{\"corruption\":127.0,\"corruption_resistance\":85.0,\"effective_corruption\":789.0}}"
        }
      end)

      assert WowMetrics.players_statistics(@token, @players) == [
        %WowMetrics.Player{effective_corruption: 123.0, name: "Nikolei"},
        %{"code" => 403, "detail" => "Forbidden", "type" => "BLZWEBAPI00000403"},
        %WowMetrics.Player{effective_corruption: 789.0, name: "Faölin"}
      ]
    end
  end

end
