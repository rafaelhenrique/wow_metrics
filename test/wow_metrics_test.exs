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

end
