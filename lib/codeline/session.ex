defmodule Codeline.Session do
  @moduledoc false

  use GenServer

  require Logger

  alias Codeline.Protocol
  alias Codeline.Store

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    socket = Keyword.fetch!(opts, :socket)
    admin_code = Keyword.fetch!(opts, :admin_code)

    {:ok,
     %{
       socket: socket,
       admin_code: admin_code,
       protocol: Protocol.initial()
     }}
  end

  @impl true
  def handle_info(:start_session, state) do
    with :ok <- send_text(state.socket, "BoW Code-Line for the Information Super Highway\r\n"),
         :ok <- send_text(state.socket, "version 2.0 -- #hack - K-RaD in '26 -\r\n"),
         :ok <- send_motd(state.socket),
         :ok <- send_text(state.socket, Protocol.prompt(:main)) do
      send(self(), :recv)
      {:noreply, state}
    else
      {:error, :closed} ->
        {:stop, :normal, state}

      {:error, reason} ->
        Logger.warning("session start failed: #{inspect(reason)}")
        {:stop, reason, state}
    end
  end

  def handle_info(:recv, state) do
    case :gen_tcp.recv(state.socket, 0) do
      {:ok, data} ->
        line = String.trim_trailing(data, "\n") |> String.trim_trailing("\r")

        {next_protocol, actions} = Protocol.handle_line(state.protocol, line, state.admin_code)

        case run_actions(actions, %{state | protocol: next_protocol}) do
          {:stop, next_state} ->
            {:stop, :normal, next_state}

          {:continue, next_state} ->
            send(self(), :recv)
            {:noreply, next_state}
        end

      {:error, :closed} ->
        {:stop, :normal, state}

      {:error, reason} ->
        Logger.warning("session recv failed: #{inspect(reason)}")
        {:stop, reason, state}
    end
  end

  @impl true
  def handle_info(:shutdown_vm, state) do
    spawn(fn ->
      Process.sleep(100)
      :init.stop()
    end)

    {:noreply, state}
  end

  @impl true
  def terminate(_reason, state) do
    :gen_tcp.close(state.socket)
    :ok
  end

  defp run_actions(actions, state) do
    Enum.reduce_while(actions, {:continue, state}, fn action, {:continue, current_state} ->
      case action do
        {:send, text} ->
          continue_or_stop(send_text(current_state.socket, text), current_state)

        {:prompt, :main} ->
          continue_or_stop(send_text(current_state.socket, Protocol.prompt(:main)), current_state)

        {:prompt, :admin} ->
          continue_or_stop(send_text(current_state.socket, Protocol.prompt(:admin)), current_state)

        {:add_code, line} ->
          :ok = Store.add_code(line)
          {:cont, {:continue, current_state}}

        :list_codes ->
          continue_or_stop(list_codes(current_state.socket), current_state)

        :clear_codes ->
          :ok = Store.clear_codes()
          {:cont, {:continue, current_state}}

        {:set_motd, motd} ->
          :ok = Store.set_motd(motd)
          {:cont, {:continue, current_state}}

        :shutdown ->
          send(self(), :shutdown_vm)
          {:halt, {:stop, current_state}}

        :close ->
          {:halt, {:stop, current_state}}
      end
    end)
  end

  defp list_codes(socket) do
    case Store.list_codes() do
      [] ->
        send_text(socket, "No codes at this time.\r\n")

      lines ->
        Enum.reduce_while(lines, :ok, fn line, :ok ->
          case send_text(socket, line <> "\r\n") do
            :ok -> {:cont, :ok}
            {:error, reason} -> {:halt, {:error, reason}}
          end
        end)
    end
  end

  defp send_motd(socket) do
    case Store.get_motd() do
      "" -> :ok
      motd -> send_text(socket, motd <> "\r\n")
    end
  end

  defp continue_or_stop(:ok, state), do: {:cont, {:continue, state}}

  defp continue_or_stop({:error, :closed}, state), do: {:halt, {:stop, state}}

  defp continue_or_stop({:error, reason}, state) do
    Logger.warning("session send failed: #{inspect(reason)}")
    {:halt, {:stop, state}}
  end

  defp send_text(socket, text) when is_binary(text) do
    :gen_tcp.send(socket, text)
  end
end
