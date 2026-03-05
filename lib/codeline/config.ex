defmodule Codeline.Config do
  @moduledoc false

  @default_listen_port 2323
  @default_admin_code "2el84u"

  def load do
    %{
      listen_port: int_env("CODELINE_LISTEN_PORT", @default_listen_port),
      admin_code: str_env("CODELINE_ADMIN_CODE", @default_admin_code),
      default_motd: str_env("CODELINE_DEFAULT_MOTD", ""),
      start_listener: Application.get_env(:codeline, :start_listener, true)
    }
  end

  defp int_env(name, default) do
    case System.get_env(name) do
      nil ->
        default

      value ->
        case Integer.parse(value) do
          {int_value, ""} -> int_value
          _ -> default
        end
    end
  end

  defp str_env(name, default), do: System.get_env(name) || default
end
