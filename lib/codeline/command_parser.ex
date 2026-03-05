defmodule Codeline.CommandParser do
  @moduledoc false

  def parse_main(line), do: parse(line, [:post, :list, :admin, :quit])

  def parse_admin(line), do: parse(line, [:clear, :motd, :kill, :quit])

  def admin_code_valid?(entered, expected) when is_binary(entered) and is_binary(expected) do
    entered == expected
  end

  defp parse(line, allowed) when is_binary(line) do
    command = normalize(line)

    case command do
      "" ->
        :empty

      "?" ->
        :help

      _ ->
        parsed =
          case command do
            "POST" -> :post
            "LIST" -> :list
            "ADMIN" -> :admin
            "QUIT" -> :quit
            "CLEAR" -> :clear
            "MOTD" -> :motd
            "KILL" -> :kill
            _ -> {:unknown, command}
          end

        case parsed do
          {:unknown, _} ->
            parsed

          cmd ->
            if Enum.member?(allowed, cmd), do: cmd, else: {:unknown, command}
        end
    end
  end

  def normalize(line) do
    line
    |> String.trim()
    |> String.upcase()
  end
end
