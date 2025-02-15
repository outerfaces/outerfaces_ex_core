defmodule Outerfaces.Endpoints.DefaultInitializer do
  @moduledoc """
  Example Outerfaces endpoints application initializer
  """
  require Logger

  alias Outerfaces.Endpoints.DynamicLoader.DefaultDynamicLoader
  alias Outerfaces.Supervisors.OuterfacesSupervisor

  @base_port 5000

  @spec supervisor(
          otp_app_slug :: atom(),
          web_app_module :: atom(),
          project_directory_names :: [String.t()],
          opts :: Keyword.t() | nil
        ) ::
          {module(), Keyword.t()} | nil
  def supervisor(otp_app_slug, web_app_module, projects, opts) do
    show_deprecation_warning()
    do_build_supervisor(
      otp_app_slug,
      web_app_module,
      projects,
      @base_port,
      opts
    )
  end

  def show_deprecation_warning() do
    Logger.warning("""
      Deprecation Warning:
      You are using #{__MODULE__}, which is intended as a starting point.
      Please create a module for initialization in place of this.
    """)
  end

  @spec do_build_supervisor(
          otp_app_slug :: atom(),
          web_app_module :: atom(),
          project_directory_names :: [String.t()],
          base_port :: pos_integer(),
          opts :: Keyword.t()
        ) :: {module(), Keyword.t()} | nil
  defp do_build_supervisor(_, _, [], _, _), do: nil

  defp do_build_supervisor(otp_app, web_app, outerfaces_projects, base_port, opts)
       when is_atom(otp_app) and is_atom(web_app) and is_list(outerfaces_projects) and
              is_integer(base_port) do
    case DefaultDynamicLoader.prepare_endpoint_modules(
           outerfaces_projects,
           otp_app,
           web_app,
           opts
         ) do
      {:error, message} ->
        Logger.error("#{__MODULE__}: Failed to generate Outerfaces endpoint modules: #{message}")
        {OuterfacesSupervisor, []}

      :ok ->
        endpoints =
          DefaultDynamicLoader.hydrate_endpoint_modules(
            outerfaces_projects,
            otp_app,
            web_app,
            base_port + 1
          )

        {OuterfacesSupervisor, endpoints}
    end
  end
end
