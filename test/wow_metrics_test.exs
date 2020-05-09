defmodule WowMetricsTest do
  use ExUnit.Case
  # doctest WowMetrics
  alias Http.Mock
  import Mox

  setup :verify_on_exit!

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
