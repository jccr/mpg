defmodule Mpg.Game do
  use GenServer, restart: :transient
  alias Phoenix.PubSub

  @initial_state %{players: [], code: nil}

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
  def init(name) do
    {:ok, %{@initial_state | code: name}, @timeout}
  end

  @impl true
  def handle_call(:list_players, _from, state) do
    {:reply, state.players, state, @timeout}
  end

  @impl true
  def handle_call({:add_player, new_player}, _from, state) do
    state =
      if !(new_player in state.players) do
        %{state | players: [new_player | state.players]}
      else
        state
      end

    # Map.update!(state, :players, fn existing_players ->
    #   [new_player | existing_players]
    # end)

    PubSub.broadcast(Mpg.PubSub, state.code, {:players, state.players})
    {:reply, :player_added, state, @timeout}
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
