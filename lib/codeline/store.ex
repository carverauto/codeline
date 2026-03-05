defmodule Codeline.Store do
  @moduledoc false

  use GenServer

  @meta_table :codeline_meta
  @codes_table :codeline_codes

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def add_code(line) when is_binary(line) do
    GenServer.call(__MODULE__, {:add_code, line})
  end

  def list_codes do
    GenServer.call(__MODULE__, :list_codes)
  end

  def clear_codes do
    GenServer.call(__MODULE__, :clear_codes)
  end

  def get_motd do
    GenServer.call(__MODULE__, :get_motd)
  end

  def set_motd(motd) when is_binary(motd) do
    GenServer.call(__MODULE__, {:set_motd, motd})
  end

  @impl true
  def init(opts) do
    initial_motd = Keyword.get(opts, :initial_motd, "")

    :ets.new(@meta_table, [:named_table, :public, :set, read_concurrency: true])
    :ets.new(@codes_table, [:named_table, :public, :ordered_set, write_concurrency: true])

    true = :ets.insert(@meta_table, {:next_id, 0})
    true = :ets.insert(@meta_table, {:motd, initial_motd})

    {:ok, %{}}
  end

  @impl true
  def handle_call({:add_code, line}, _from, state) do
    id = :ets.update_counter(@meta_table, :next_id, {2, 1})
    true = :ets.insert(@codes_table, {id, line})
    {:reply, :ok, state}
  end

  def handle_call(:list_codes, _from, state) do
    codes =
      @codes_table
      |> :ets.tab2list()
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map(&elem(&1, 1))

    {:reply, codes, state}
  end

  def handle_call(:clear_codes, _from, state) do
    :ets.delete_all_objects(@codes_table)
    {:reply, :ok, state}
  end

  def handle_call(:get_motd, _from, state) do
    motd =
      case :ets.lookup(@meta_table, :motd) do
        [{:motd, value}] -> value
        _ -> ""
      end

    {:reply, motd, state}
  end

  def handle_call({:set_motd, motd}, _from, state) do
    true = :ets.insert(@meta_table, {:motd, motd})
    {:reply, :ok, state}
  end
end
