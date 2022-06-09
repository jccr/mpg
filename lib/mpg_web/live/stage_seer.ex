defmodule StageSeer do
  use MpgWeb, :live_component
  alias Mpg.Game

  def render(assigns) do
    player_list = assigns.code |> Game.list_players()
    chosen_player = Enum.at(Enum.shuffle(player_list -- [assigns.player_name]), 0)
    player_card = assigns.code |> Game.get_player_card(chosen_player)

    ~H"""
    <section class="inline-block">
      <h1 class="text-3xl">Wake up, <%= Game.role_cards[:seer] %> Seer!</h1>
        <p>You use your magical powers on someone to reveal...</p>
        <p>This person is actually this role!</p>
        <p>You feel like you've got to do something about this.</p>
        <figure class="flex flex-col mt-6 gap-1">
        <span class="box text-xl flex items-center justify-center gap-4">
          <span class="text-3xl"><%= Game.role_cards[player_card] %></span>
          <%= chosen_player %>
        </span>
        </figure>
    </section>
    """
  end
end
