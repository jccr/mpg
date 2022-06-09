defmodule StageRobber do
  use MpgWeb, :live_component
  alias Mpg.Game

  def render(assigns) do
    player_list = assigns.code |> Game.list_players()
    chosen_player = Enum.at(Enum.shuffle(player_list -- [assigns.player_name]), 0)
    player_card = assigns.code |> Game.get_player_card(chosen_player)
    assigns.code |> Game.swap_player_cards(assigns.player_name, chosen_player)

    ~H"""
    <section class="inline-block">
      <h1 class="text-3xl">Wake up, <%= Game.role_cards[:robber] %> Robber!</h1>
        <p>You feel like you could gain from taking something...</p>
        <p>You have stolen the role of a victim! You are now known for this role.</p>
        <p>As a final misgiving, you also frame this person as the Robber!</p>
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
