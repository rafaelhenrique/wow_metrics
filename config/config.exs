# General application configuration
import Config

config :wow_metrics,
  client_id: System.get_env("CLIENT_ID"),
  client_secret: System.get_env("CLIENT_SECRET"),
  oauth_url: System.get_env("OAUTH_URL"),
  http_adapter: HTTPoison


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
