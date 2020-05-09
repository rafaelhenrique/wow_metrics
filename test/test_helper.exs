ExUnit.start()

defmodule Http.Behaviour do
  @doc """
    This class is a interface/abstract class to HTTPoison methods.

    References:
      https://github.com/edgurgel/httpoison/blob/v1.6.2/lib/httpoison/base.ex#L194-L201
      https://blog.lelonek.me/how-to-mock-httpoison-in-elixir-7947917a9266
      https://elixirforum.com/t/how-to-mock-httpoison-with-mox/19370
  """

  @type response :: Response.t()
  @type request :: Request.t()
  @type method :: Request.method()
  @type url :: Request.url()
  @type headers :: Request.headers()
  @type body :: Request.body()
  @type options :: Request.options()
  @type params :: Request.params()

  @callback get!(url, headers) :: Response.t() | AsyncResponse.t()
end

Mox.defmock(
  Http.Mock,
  for: Http.Behaviour
)