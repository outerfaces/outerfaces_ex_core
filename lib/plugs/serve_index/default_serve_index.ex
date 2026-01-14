defmodule Outerfaces.Plugs.ServeIndex.DefaultServeIndex do
  @moduledoc """
  A default example plug to handle both static asset requests and index.html fallback.
  """

  import Plug.Conn

  @behaviour Plug

  @impl true
  def init(opts) do
    static_root = Keyword.get(opts, :static_root, "priv/static")
    root = Path.expand(static_root)
    index_path = Keyword.get(opts, :index_path, Path.join(root, "index.html")) |> Path.expand()

    %{
      index_path: index_path,
      static_root: root,
      static_patterns: Keyword.get(opts, :static_patterns, default_static_patterns())
    }
  end

  @impl true
  def call(conn, %{
        index_path: index_path,
        static_root: static_root,
        static_patterns: static_patterns
      })
      when is_binary(index_path) and is_list(static_patterns) and is_binary(static_root) do
    request_path = conn.request_path

    cond do
      static_asset_request?(request_path, static_patterns) ->
        serve_static_asset(conn, static_root, request_path)

      true ->
        serve_index_html(conn, index_path)
    end
  end

  defp serve_static_asset(conn, root, request_path) do
    with false <- String.contains?(request_path, <<0>>),
         rel <- String.trim_leading(request_path, "/"),
         false <- String.contains?(rel, ["\\", ":"]),
         candidate <- Path.expand(rel, root),
         true <- candidate == root or String.starts_with?(candidate, root <> "/"),
         true <- File.regular?(candidate) do
      mime_type = MIME.from_path(candidate) || "application/octet-stream"

      conn
      |> put_resp_content_type(mime_type)
      |> send_file(200, candidate)
      |> halt()
    else
      _ ->
        conn |> send_resp(404, "File not found") |> halt()
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
