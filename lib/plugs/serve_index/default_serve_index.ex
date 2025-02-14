defmodule Outerfaces.Plugs.ServeIndex.DefaultServeIndex do
  @moduledoc """
  Default Outerfaces plug to handle both static asset requests and index.html fallback.
  """

  import Plug.Conn

  @behaviour Plug

  @impl true
  def init(opts) do
    %{
      index_path: Keyword.get(opts, :index_path, "priv/static/index.html"),
      static_root: Keyword.get(opts, :static_root, "priv/static"),
      static_patterns: Keyword.get(opts, :static_patterns, default_static_patterns())
    }
  end

  @impl true
  def call(conn, %{
        index_path: index_path,
        static_root: static_root,
        static_patterns: static_patterns
      })
      when is_binary(index_path) and is_binary(static_root) and is_list(static_patterns) do
    request_path = conn.request_path

    cond do
      static_asset_request?(request_path, static_patterns) ->
        serve_static_asset(conn, static_root, request_path)

      true ->
        serve_index_html(conn, index_path)
    end
  end

  defp serve_static_asset(conn, static_root, request_path) do
    relative_request_path = String.trim_leading(request_path, "/")
    full_path = Path.expand(Path.join(static_root, relative_request_path))

    if File.exists?(full_path) and not File.dir?(full_path) do
      mime_type = MIME.from_path(full_path) || "application/octet-stream"

      conn
      |> put_resp_content_type(mime_type)
      |> send_file(200, full_path)
      |> halt()
    else
      send_resp(conn, 404, "File not found")
      |> halt()
    end
  end

  defp serve_index_html(conn, index_path) do
    if File.exists?(index_path) do
      conn
      |> put_resp_content_type("text/html")
      |> send_file(200, index_path)
      |> halt()
    else
      send_resp(conn, 404, "index.html not found")
      |> halt()
    end
  end

  defp static_asset_request?(request_path, patterns) do
    Enum.any?(patterns, &Regex.match?(&1, request_path))
  end

  defp default_static_patterns do
    [
      ~r{\.html$},
      ~r{\.js$},
      ~r{\.css$},
      ~r{\.png$},
      ~r{\.jpg$},
      ~r{\.svg$},
      ~r{\.json$},
      ~r{\.ico$},
      ~r{\.txt$}
    ]
  end
end
