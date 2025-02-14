defmodule Outerfaces.Supervisors.OuterfacesSupervisor do
  @moduledoc """
  A supervisor for all Outerfaces project endpoints.

  This module also has the functions for stopping and restarting endpoints.
  """
  use Supervisor

  def start_link(endpoints)
      when is_list(endpoints),
      do: Supervisor.start_link(__MODULE__, endpoints, name: __MODULE__)

  @impl true
  def init(endpoints) when is_list(endpoints),
    do: Supervisor.init(endpoints, strategy: :one_for_one)

  def stop_endpoint(endpoint_module)
      when is_atom(endpoint_module),
      do: Supervisor.terminate_child(__MODULE__, endpoint_module)

  def restart_endpoint(endpoint_module)
      when is_atom(endpoint_module),
      do: Supervisor.restart_child(__MODULE__, endpoint_module)
end
