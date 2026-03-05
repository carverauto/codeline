defmodule Codeline.Application do
  @moduledoc false

  use Application

  alias Codeline.Config

  @impl true
  def start(_type, _args) do
    config = Config.load()

    children =
      [
        {Codeline.Store, initial_motd: config.default_motd},
        {DynamicSupervisor, strategy: :one_for_one, name: Codeline.SessionSupervisor}
      ] ++ listener_children(config)

    Supervisor.start_link(children, strategy: :one_for_one, name: Codeline.Supervisor)
  end

  defp listener_children(%{start_listener: true, listen_port: port, admin_code: admin_code}) do
    [{Codeline.Listener, port: port, admin_code: admin_code}]
  end

  defp listener_children(_config), do: []
end
