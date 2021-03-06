defmodule StageTroublemaker do
  use MpgWeb, :live_component
  alias Mpg.Game

  def render(assigns) do
    player_list = assigns.code |> Game.list_players()
    shuffled_players = Enum.shuffle(player_list -- [assigns.player_name])
    chosen_player_1 = Enum.at(shuffled_players, 0)
    chosen_player_2 = Enum.at(shuffled_players, 1)

    assigns.code |> Game.swap_player_cards(chosen_player_1, chosen_player_2)

    ~H"""
    <section class="inline-block">
      <h1 class="text-3xl mb-6">Wake up, <%= Game.role_cards[:troublemaker] %> Troublemaker!</h1>
        <p>You feel like up to no good, and want to cause mischief on the townsfolk.</p>
        <p class="font-bold my-2 text-xl">You manage to swap the roles of two others!</p>
        <figure class="flex flex-col mt-6 gap-1">
        <span class="box text-xl flex items-center justify-center gap-4">
          <%= chosen_player_1 %>
        </span>
        <span class="text-3xl">🔃</span>
        <span class="box text-xl flex items-center justify-center gap-4">
          <%= chosen_player_2 %>
        </span>
        </figure>
    </section>
    """
  end
end
