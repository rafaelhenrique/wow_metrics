import Config

config :wow_metrics,
  client_id: "secret_shhhh!",
  client_secret: "secret_shhhh!",
  oauth_url: "https://testing.land.com/oauth/token?grant_type=client_credentials",
  http_adapter: Http.Mock
