defmodule Mpg.Game do
  use GenServer, restart: :transient
  alias Phoenix.PubSub

  @initial_state %{
    code: nil,
    players: [],
    players_status: %{},
    started: false,
    stage: nil,
    waiting_for: [],
    center_cards: [],
    player_cards: %{},
    player_roles: %{},
    player_votes: %{}
  }

  # shutdown after 15 mins of inactivity
  @timeout 15 * 60 * 1000

  @vote_time 3 * 60 * 1000

  def role_cards do
    [werewolf: "🐺", seer: "🧙‍♀️", robber: "😈", troublemaker: "🤭", villager: "🧑‍🌾"]
  end

  ## API
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def get_internal_state(game_code) do
    game_code |> via_tuple() |> GenServer.call(:get_internal_state)
  end

  def add_player(game_code, player_name) do
    game_code |> via_tuple() |> GenServer.call({:add_player, player_name})
  end

  def drop_player(game_code, player_name) do
    game_code |> via_tuple() |> GenServer.call({:drop_player, player_name})
  end

  def list_players(game_code) do
    game_code |> via_tuple() |> GenServer.call(:list_players)
  end

  def start(game_code) do
    game_code |> via_tuple() |> GenServer.call(:start)
  end

  def stop(game_code, reason \\ :normal) do
    game_code |> via_tuple() |> GenServer.stop(reason)
  end

  def exists(game_code) do
    !(Registry.lookup(Mpg.GameRegistry, game_code) == [])
  end

  def get_center_cards(game_code) do
    game_code |> via_tuple() |> GenServer.call(:get_center_cards)
  end

  def get_player_card(game_code, player_name) do
    game_code |> via_tuple() |> GenServer.call({:get_player_card, player_name})
  end

  def get_player_role(game_code, player_name) do
    game_code |> via_tuple() |> GenServer.call({:get_player_role, player_name})
  end

  def get_player_role_partners(game_code, player_name) do
    game_code |> via_tuple() |> GenServer.call({:get_player_role_partners, player_name})
  end

  def get_state_for_player(game_code, player_name) do
    game_code |> via_tuple() |> GenServer.call({:get_state_for_player, player_name})
  end

  def swap_player_cards(game_code, from_player, to_player) do
    game_code |> via_tuple() |> GenServer.call({:swap_player_cards, from_player, to_player})
  end

  def continue(game_code, player_name) do
    game_code |> via_tuple() |> GenServer.call({:continue, player_name})
  end

  def vote_for_player(game_code, player_name) do
    game_code |> via_tuple() |> GenServer.call({:vote_for_player, player_name})
  end

  def get_conclusion(game_code) do
    game_code |> via_tuple() |> GenServer.call(:get_conclusion)
  end

  ## GenServer callbacks
  @impl true
  def init(name) do
    {:ok, %{@initial_state | code: name}, @timeout}
  end

  @impl true
  def handle_call(:list_players, _from, state) do
    {:reply, all_players(state.players_status), state, @timeout}
  end

  def handle_call(:get_internal_state, _from, state) do
    {:reply, state, state, @timeout}
  end

  def handle_call(:get_center_cards, _from, state) do
    {:reply, state.center_cards, state, @timeout}
  end

  def handle_call({:get_player_card, player}, _from, state) do
    {:reply, state.player_cards[player], state, @timeout}
  end

  def handle_call({:get_player_role, player}, _from, state) do
    {:reply, state.player_roles[player], state, @timeout}
  end

  def handle_call({:get_player_role_partners, player}, _from, state) do
    player_role = state.player_roles[player]

    {
      :reply,
      (state.player_roles
       |> Enum.filter(fn {_k, v} -> v == player_role end)
       |> Map.new()
       |> Map.keys()) -- [player],
      state,
      @timeout
    }
  end

  def handle_call({:get_state_for_player, player}, _from, state) do
    {:reply,
     %{
       started: state.started,
       stage: state.stage,
       stage_matches_role: state.player_roles[player] == state.stage,
       waiting: state.waiting_for != [],
       waiting_on_you: player in state.waiting_for
     }, state, @timeout}
  end

  def handle_call({:swap_player_cards, from_player, to_player}, _from, state) do
    from_player_card = state.player_cards[from_player]
    to_player_card = state.player_cards[to_player]

    new_player_cards =
      state.player_cards
      |> Map.put(from_player, to_player_card)
      |> Map.put(to_player, from_player_card)

    {:reply, :swapped_cards, %{state | player_cards: new_player_cards}, @timeout}
  end

  def handle_call({:continue, player}, _from, state) do
    Task.start_link(fn ->
      PubSub.broadcast(Mpg.PubSub, state.code, :state_changed)
    end)

    continue_next_stage(state, player)
  end

  def handle_call({:vote_for_player, player}, _from, state) do
    vote_count = (state.player_votes[player] || 0) + 1
    player_votes = Map.put(state.player_votes, player, vote_count)
    {:reply, %{state | player_votes: player_votes}, state, @timeout}
  end

  def handle_call(:get_conclusion, _from, state) do
    {:reply, %{player_cards: state.player_cards, player_votes: state.player_votes}, state,
     @timeout}
  end

  def handle_call(:start, _from, state) do
    players = all_players(state.players_status)
    player_count = length(players)

    if player_count < 3 do
      {:reply, :not_enough_players, state, @timeout}
    else
      Task.start_link(fn ->
        PubSub.broadcast(Mpg.PubSub, state.code, :state_changed)
      end)

      {center_cards, player_cards} = assign_cards(role_sets(player_count), players)

      {:reply, :started,
       %{
         state
         | started: true,
           waiting_for: players,
           stage: List.first(stages()),
           center_cards: center_cards,
           player_cards: player_cards,
           player_roles: player_cards
       }, @timeout}
    end
  end

  def handle_call({:add_player, player}, _from, state) do
    {reply, state} =
      if player not in state.players do
        {:player_added,
         %{
           state
           | players: [player | state.players],
             players_status: Map.put(state.players_status, player, connected: true)
         }}
      else
        {:player_already_added, state}
      end

    PubSub.broadcast(Mpg.PubSub, state.code, {:players, state.players})

    {:reply, reply, state, @timeout}
  end

  def handle_call({:drop_player, player}, _from, state) do
    {reply, state} =
      if state.started do
        {:player_disconnected,
         %{
           state
           | players: List.delete(state.players, player),
             players_status: Map.put(state.players_status, player, connected: false)
         }}
      else
        {:player_dropped,
         %{
           state
           | players: List.delete(state.players, player),
             players_status: Map.delete(state.players_status, player)
         }}
      end

    PubSub.broadcast(Mpg.PubSub, state.code, {:players, state.players})

    {:reply, reply, state, @timeout}
  end

  @impl true
  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  ## Private functions

  defp via_tuple(name) do
    {:via, Registry, {Mpg.GameRegistry, name}}
  end

  defp active_roles do
    [:werewolf, :seer, :robber, :troublemaker]
  end

  defp passive_roles do
    [:villager]
  end

  defp roles do
    active_roles() ++ passive_roles()
  end

  defp head_stages do
    [:roles, :player_role]
  end

  defp tail_stages do
    [:vote, :conclusion]
  end

  defp stages do
    head_stages() ++ active_roles() ++ tail_stages()
  end

  defp stages_without_roles do
    head_stages() ++ passive_roles() ++ tail_stages()
  end

  # TODO: Make this private again
  def role_sets(player_count) do
    default = [:werewolf | roles()]

    case player_count do
      3 -> default
      4 -> default ++ [:villager]
      5 -> default ++ [:villager, :villager]
    end
  end

  defp continue_next_stage(state, player) do
    waiting_for = state.waiting_for -- [player]

    if waiting_for == [] do
      stage = next_stage(stages(), state.stage)
      is_stage_without_role = Enum.member?(stages_without_roles(), stage)

      waiting_for =
        Map.filter(state.player_roles, fn {_k, v} -> v == stage end)
        |> Map.keys()
        |> case do
          [] when is_stage_without_role -> all_players(state.player_roles)
          players -> players
        end

      state = %{state | waiting_for: waiting_for, stage: stage}

      if waiting_for == [] and not is_stage_without_role do
        continue_next_stage(state, nil)
      else
        {:reply, :ok, state, @timeout}
      end
    else
      {:reply, :ok, %{state | waiting_for: waiting_for}, @timeout}
    end
  end

  defp next_stage(stages, current_stage) do
    index = Enum.find_index(stages, fn e -> e == current_stage end)
    Enum.at(stages, index + 1)
  end

  defp assign_cards(cards, players) do
    {center_cards, player_cards} =
      cards
      |> Enum.shuffle()
      |> Enum.split(3)

    {
      center_cards,
      Enum.zip(players, player_cards)
      |> Map.new()
    }
  end

  defp all_players(players_map) do
    Map.keys(players_map)
  end
end
