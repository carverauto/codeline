defmodule Codeline.Protocol do
  @moduledoc false

  alias Codeline.CommandParser

  @main_prompt "#Chases codeline [? for help]# "
  @admin_prompt "#Chases codeline admin [? for help]# "

  defstruct mode: :main, motd_buffer: []

  def initial, do: %__MODULE__{}

  def prompt(:main), do: @main_prompt
  def prompt(:admin), do: @admin_prompt

  def handle_line(%__MODULE__{mode: :main} = state, line, _admin_code) do
    case CommandParser.parse_main(line) do
      :post ->
        {put_mode(state, :post),
         [{:send, "Enter your codes now. Enter a period ('.') by itself to end\r\n"}]}

      :list ->
        {state, [:list_codes, {:prompt, :main}]}

      :admin ->
        {put_mode(state, :admin_auth), [{:send, "Please enter your access code: "}]}

      :quit ->
        {state, [{:send, "NO CARRIER\r\n"}, :close]}

      :help ->
        {state,
         [
           {:send, "\r\nValid commands are:\r\n"},
           {:send, "POST  - Post a code\r\n"},
           {:send, "LIST  - List all codes\r\n"},
           {:send, "ADMIN - Goto admin menu\r\n"},
           {:send, "QUIT  - Disconnect\r\n\r\n"},
           {:prompt, :main}
         ]}

      :empty ->
        {state, [{:prompt, :main}]}

      {:unknown, command} ->
        {state, [{:send, "#{command}: Command not found.\r\n"}, {:prompt, :main}]}
    end
  end

  def handle_line(%__MODULE__{mode: :post} = state, line, _admin_code) do
    if String.trim(line) == "." do
      {put_mode(state, :main), [{:send, "Returning to main menu..\r\n"}, {:prompt, :main}]}
    else
      {state, [{:add_code, String.trim_trailing(line)}]}
    end
  end

  def handle_line(%__MODULE__{mode: :admin_auth} = state, line, admin_code) do
    if CommandParser.admin_code_valid?(String.trim(line), admin_code) do
      {put_mode(state, :admin), [{:send, "Access granted.\r\n"}, {:prompt, :admin}]}
    else
      {put_mode(state, :main), [{:send, "Access denied.\r\n"}, {:prompt, :main}]}
    end
  end

  def handle_line(%__MODULE__{mode: :admin} = state, line, _admin_code) do
    case CommandParser.parse_admin(line) do
      :clear ->
        {state, [:clear_codes, {:send, "All codes have been deleted.\r\n"}, {:prompt, :admin}]}

      :motd ->
        {put_mode(%{state | motd_buffer: []}, :admin_motd),
         [{:send, "Enter the new MOTD, end with a period ('.') on a line by itself\r\n"}]}

      :kill ->
        {state, [{:send, "Server shutting down.\r\n"}, :shutdown]}

      :quit ->
        {put_mode(state, :main), [{:send, "Returning to main menu..\r\n"}, {:prompt, :main}]}

      :help ->
        {state,
         [
           {:send, "\r\nValid commands are:\r\n"},
           {:send, "CLEAR - Erase all the codes\r\n"},
           {:send, "MOTD  - Change the login greeting\r\n"},
           {:send, "KILL  - Kill the codeline service\r\n"},
           {:send, "QUIT  - Quit back to main menu\r\n\r\n"},
           {:prompt, :admin}
         ]}

      :empty ->
        {state, [{:prompt, :admin}]}

      {:unknown, command} ->
        {state, [{:send, "#{command}: Command not found.\r\n"}, {:prompt, :admin}]}
    end
  end

  def handle_line(%__MODULE__{mode: :admin_motd, motd_buffer: lines} = state, line, _admin_code) do
    if String.trim(line) == "." do
      motd = Enum.reverse(lines) |> Enum.join("\n")

      {put_mode(%{state | motd_buffer: []}, :admin),
       [{:set_motd, motd}, {:send, "MOTD updated.\r\n"}, {:prompt, :admin}]}
    else
      {%{state | motd_buffer: [String.trim_trailing(line) | lines]}, []}
    end
  end

  defp put_mode(state, mode), do: %{state | mode: mode}
end
