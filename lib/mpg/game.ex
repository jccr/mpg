defmodule Mpg.Game do
  use GenServer, restart: :transient

  @initial_state %{players: []}

  # shutdown after 15 mins of inactivity
  @timeout 15 * 60 * 1000

  ## API
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def add_player(game_code, player_name) do
    game_code |> via_tuple() |> GenServer.call({:add_player, player_name})
  end

  def list_players(game_code) do
    game_code |> via_tuple() |> GenServer.call(:list_players)
  end

  def stop(game_code, reason \\ :normal) do
    game_code |> via_tuple() |> GenServer.stop(reason)
  end

  def exists(game_code) do
    !(Registry.lookup(Mpg.GameRegistry, game_code) == [])
  end

  ## GenServer callbacks
  @impl true
  def init(_name) do
    {:ok, @initial_state, @timeout}
  end

  @impl true
  def handle_call(:list_players, _from, state) do
    {:reply, state.players, state, @timeout}
  end

  @impl true
  def handle_call({:add_player, new_player}, _from, state) do
    new_state =
      Map.update!(state, :players, fn existing_players ->
        [new_player | existing_players]
      end)

    {:reply, :player_added, new_state, @timeout}
  end

  @impl true
  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  ## Private functions

  defp via_tuple(name) do
    {:via, Registry, {Mpg.GameRegistry, name}}
  end
end
