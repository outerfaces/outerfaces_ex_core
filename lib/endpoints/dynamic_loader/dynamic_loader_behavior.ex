defmodule Outerfaces.Endpoints.DynamicLoader.DynamicLoaderBehavior do
  @moduledoc """
  A behaviour module that outlines the required callbacks for DynamicLoader.
  """

  @doc """
  Returns the endpoint config for the given arguments
  """
  @callback endpoint_config_for_project(
              project_name :: String.t(),
              dynamic_port :: pos_integer(),
              app_web_module :: atom()
            ) :: Keyword.t()

  @doc """
  Builds an endpoint module for a project for the given arguments.

  This allows developers to define custom endpoint plug pipelines for each project's endpoint.
  """
  @callback prepare_endpoint_module(
              outerfaces_project_name :: String.t(),
              otp_app_slug :: atom(),
              built_endpoint_mdoule :: atom(),
              opts :: Keyword.t() | nil
            ) :: :ok | no_return()

  @doc """
  Builds modules to define endpoints for each outerfaces project.
  """
  @callback prepare_endpoint_modules(
              project_directory_names :: [String.t()],
              otp_app_slug :: atom(),
              app_web_module :: atom(),
              opts :: Keyword.t() | nil
            ) ::
              :ok | {:error, String.t()}

  @doc """
  Compiles and returns a list of the instantiated endpoint modules for each project.
  """
  @callback hydrate_endpoint_modules(
              project_directory_names :: [String.t()],
              otp_app_slug :: atom(),
              app_web_module :: atom(),
              base_port :: pos_integer()
            ) :: [{atom(), Keyword.t()}]

  @doc """
  Returns a dynamic port number using the base port and index of the project * ports per project
  """
  @callback dynamic_port(
              base_port :: non_neg_integer(),
              project_index :: non_neg_integer()
            ) :: pos_integer()

  @doc """
  Creates the endpoint module for a project with a given outerfaces_project_name, app slug, and (dynamically generated) endpoint_module.
  Adds the built endpoint module to the given app web module, and adds the endpoint config to app config for the given app slug.
  """
  @callback create_dynamic_endpoint_spec(
              project_name_with_index :: {String.t(), non_neg_integer()},
              otp_app_slug :: atom(),
              app_web_module :: atom(),
              project_base_port :: pos_integer()
            ) :: {atom(), Keyword.t()}
end
