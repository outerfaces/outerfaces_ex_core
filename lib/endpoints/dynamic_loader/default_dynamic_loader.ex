defmodule Outerfaces.Endpoints.DynamicLoader.DefaultDynamicLoader do
  @moduledoc """
  Custom endpoint loader for Outerfaces projects.
  """
  @projects_dir_name "outerfaces"
  @ports_per_project 2
  @default_base_port 4242

  @behaviour Outerfaces.Endpoints.DynamicLoader.DynamicLoaderBehavior

  require Logger

  def show_deprecation_warning() do
    Logger.warning("""
      Deprecation Warning:
      You are using #{__MODULE__}, which is intended as a starting point.
      Please set your project-specific configurations in place of these.
    """)
  end

  @impl true
  def endpoint_config_for_project(project_name, port, app_web_module)
      when is_binary(project_name) and is_integer(port) and is_atom(app_web_module) do
    show_deprecation_warning()
    Logger.debug("#{__MODULE__} Creating endpoint config for #{project_name}")

    [
      http: [ip: {127, 0, 0, 1}, port: port],
      url: [host: "localhost", port: port, scheme: "http"],
      # https: [
      #   port: port + 1,
      #   ip: {127, 0, 0, 1},
      #   cipher_suite: :strong,
      #   keyfile: "priv/cert/localhost-key.pem",
      #   certfile: "priv/cert/localhost.pem"
      # ],
      # url: [host: "localhost", port: port + 1, scheme: "https"],
      secret_key_base: System.get_env("SECRET_KEY_BASE"),
      adapter: Bandit.PhoenixAdapter,
      render_errors: [
        formats: [json: Module.concat([app_web_module, ErrorJSON])],
        layout: false
      ]
    ]
  end

  @impl true
  def prepare_endpoint_module(project_name, app_slug, endpoint_module, _opts)
      when is_binary(project_name) and is_atom(app_slug) and is_atom(endpoint_module) do
    unless Code.ensure_loaded?(endpoint_module) do
      project_path =
        [
          :code.priv_dir(app_slug),
          "static",
          @projects_dir_name,
          "projects",
          project_name
        ]
        |> Path.join()

      module_body =
        quote do
          use Phoenix.Endpoint, otp_app: unquote(app_slug)

          plug(Plug.Logger, log: :debug)

          plug(Outerfaces.Plugs.CSP.DefaultCSP)

          plug(Outerfaces.Plugs.ServeIndex.DefaultServeIndex,
            index_path: "#{unquote(project_path)}/index.html",
            static_root: unquote(project_path)
          )
        end

      Module.create(endpoint_module, module_body, Macro.Env.location(__ENV__))
    end
  end

  @impl true
  def prepare_endpoint_modules(project_directories, app_slug, app_web_module, opts)
      when is_list(project_directories) and is_atom(app_slug) and
             is_atom(app_web_module) and is_list(opts) do
    Logger.debug("#{__MODULE__}: Generating endpoint modules")

    Enum.each(project_directories, fn project ->
      prepare_endpoint_module(
        project,
        app_slug,
        endpoint_module_name(app_web_module, project),
        opts
      )
    end)
  end

  @impl true
  def hydrate_endpoint_modules(
        project_directories,
        app_module,
        app_web_module,
        base_port \\ @default_base_port
      )
      when is_list(project_directories) and is_atom(app_module) and
             is_atom(app_web_module) and is_integer(base_port) do
    Logger.debug("#{__MODULE__}: Initializing generated endpoint modules")

    project_directories
    |> Enum.with_index()
    |> Enum.map(&create_dynamic_endpoint_spec(&1, app_module, app_web_module, base_port))
  end

  @impl true
  @spec create_dynamic_endpoint_spec(
          {String.t(), non_neg_integer()},
          atom(),
          atom(),
          pos_integer()
        ) :: {atom(), Keyword.t()}
  def create_dynamic_endpoint_spec(
        {project_name, index},
        app_module,
        app_web_module,
        base_port
      )
      when is_binary(project_name) and is_atom(app_module) and
             is_atom(app_web_module) and is_integer(base_port) do
    Logger.debug("#{__MODULE__}: Creating dynamic endpoint spec for #{project_name}")
    port = dynamic_port(base_port, index)
    endpoint_module = endpoint_module_name(app_web_module, project_name)
    config = endpoint_config_for_project(project_name, port, app_web_module)
    Application.put_env(app_module, endpoint_module, config)
    {endpoint_module, config}
  end

  @impl true
  def dynamic_port(base_port, 0) when is_integer(base_port) do
    base_port
  end

  def dynamic_port(base_port, index) when is_integer(base_port) and is_integer(index) do
    base_port + index * @ports_per_project
  end

  defp endpoint_module_name(app_web_module, project_name)
       when is_atom(app_web_module) and is_binary(project_name) do
    camel_case_name = snake_to_camel(project_name)
    Module.concat([app_web_module, "#{camel_case_name}Endpoint"])
  end

  defp snake_to_camel(snake_case) do
    snake_case
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join()
  end
end
