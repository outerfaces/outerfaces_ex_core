defmodule Outerfaces.Plugs.ContentSecurityPolicies.DefaultCSP do
  @moduledoc """
  A plug for setting Content Security Policy headers on responses.
  """
  import Plug.Conn
  alias Plug.Conn

  @hardcoded_csp "base-uri 'none'; block-all-mixed-content; default-src 'self';" <>
                   " form-action 'self'; frame-ancestors 'none'; img-src 'self';" <>
                   " object-src 'none'; script-src 'self';" <>
                   " style-src 'self' 'unsafe-inline'; upgrade-insecure-requests"

  @allowed_origins [
    "localhost"
  ]

  @spec init(Keyword.t()) :: Keyword.t()
  def init(opts \\ []), do: opts

  @spec call(Conn.t(), Keyword.t()) :: Conn.t()
  def call(%Conn{} = conn, _opts) do
    conn
    |> register_before_send(fn conn ->
      origin = get_req_header(conn, "origin") |> List.first()

      conn =
        if origin in @allowed_origins do
          put_resp_header(conn, "access-control-allow-origin", origin)
        else
          conn
        end

      conn
      |> put_resp_header("content-security-policy", @hardcoded_csp)
      |> put_resp_header("x-content-type-options", "nosniff")
      |> put_resp_header("x-frame-options", "deny")
      |> put_resp_header(
        "strict-transport-security",
        "max-age=31536000; includeSubDomains; preload"
      )
      |> put_resp_header("referrer-policy", "no-referrer")
      |> put_resp_header("access-control-allow-methods", "GET, POST, PUT, OPTIONS")
      |> put_resp_header("access-control-allow-headers", "Content-Type, Authorization")
    end)
  end
end
