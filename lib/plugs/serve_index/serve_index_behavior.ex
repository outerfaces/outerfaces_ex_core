defmodule Outerfaces.Plugs.ServeIndex.ServeIndexBehavior do
  @moduledoc """
  A behavior module that defines the required callbacks for the ServeIndex plug.
  This module specifies the contract for ServeIndex implementations.
  """

  @type conn :: Plug.Conn.t()
  @type call_params :: %{index_path: String.t(), static_asset_patterns: [Regex.t()]}

  @callback init(params :: map()) :: call_params()
  @callback call(conn :: conn(), call_params :: call_params()) :: conn()
  @callback static_asset_request?(conn :: conn(), asset_patterns :: [Regex.t()]) :: boolean()
  @callback default_static_asset_patterns() :: [Regex.t()]
  @callback serve_static_asset(
              conn :: conn(),
              static_root :: String.t(),
              index_path :: String.t()
            ) :: conn()
  @callback serve_index_html(conn :: conn(), index_path :: String.t()) :: conn()
end
