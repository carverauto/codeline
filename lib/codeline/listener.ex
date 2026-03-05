defmodule Codeline.Listener do
  @moduledoc false

  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    port = Keyword.fetch!(opts, :port)
    admin_code = Keyword.fetch!(opts, :admin_code)

    listen_opts = [
      :binary,
      {:packet, :line},
      {:active, false},
      {:reuseaddr, true},
      {:nodelay, true},
      {:backlog, 128}
    ]

    {:ok, socket} = :gen_tcp.listen(port, listen_opts)
    Logger.info("codeline listener started on port #{port}")

    send(self(), :accept)
    {:ok, %{listen_socket: socket, admin_code: admin_code}}
  end

  @impl true
  def handle_info(:accept, state) do
    case :gen_tcp.accept(state.listen_socket) do
      {:ok, client_socket} ->
        start_session(client_socket, state.admin_code)
        send(self(), :accept)
        {:noreply, state}

      {:error, reason} ->
        Logger.error("accept failed: #{inspect(reason)}")
        Process.send_after(self(), :accept, 1000)
        {:noreply, state}
    end
  end

  defp start_session(socket, admin_code) do
    peer = peer_label(socket)
    Logger.info("client connected from #{peer}")

    child_spec = {Codeline.Session, [socket: socket, admin_code: admin_code, peer: peer]}

    with {:ok, pid} <- DynamicSupervisor.start_child(Codeline.SessionSupervisor, child_spec),
         :ok <- :gen_tcp.controlling_process(socket, pid) do
      send(pid, :start_session)
      :ok
    else
      {:error, :not_owner} ->
        :gen_tcp.close(socket)
        :error

      {:error, reason} ->
        Logger.warning("failed to start session: #{inspect(reason)}")
        :gen_tcp.close(socket)
        :error

      other ->
        Logger.warning("unexpected session startup failure: #{inspect(other)}")
        :gen_tcp.close(socket)
        :error
    end
  end

  defp peer_label(socket) do
    case :inet.peername(socket) do
      {:ok, {addr, port}} -> "#{:inet.ntoa(addr)}:#{port}"
      _ -> "unknown-peer"
    end
  end
end
