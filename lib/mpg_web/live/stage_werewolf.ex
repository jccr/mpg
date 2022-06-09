defmodule StageWerewolf do
  use MpgWeb, :live_component
  alias Mpg.Game

  def render(assigns) do
    partners = assigns.code |> Game.get_player_role_partners(assigns.player_name)
    center_card = Enum.at(assigns.code |> Game.get_center_cards(), 0)

    ~H"""
    <section class="inline-block">
      <h1 class="text-3xl">Wake up, <%= Game.role_cards[:werewolf] %> Werewolf!</h1>
      <%= if Enum.count(partners) == 0 do %>
        <p>You sniff around and realise you're a lone wolf.</p>
        <p>You sense that one character is NOT among the townsfolk.</p>
        <p>Maybe you can use this knowledge to your advantage!</p>
        <p>Remember, don't let the others find out what you are...</p>
        <figure class="flex flex-col mt-6 gap-1">
        <span class="box capitalize text-xl flex items-center justify-center gap-4">
          <span class="text-3xl"><%= Game.role_cards[center_card] %></span>
          <%= Atom.to_string(center_card) %>
        </span>
        </figure>
      <% else %>
        <p>You are not alone, there's another werewolf roaming around!</p>
        <p>Become allies and take on the town!</p>
        <p>Remember, don't let the others find out what you are...</p>
        <figure class="flex flex-col mt-6 gap-1">
        <span class="box text-xl flex items-center justify-center gap-4">
          <span class="text-3xl"><%= Game.role_cards[:werewolf] %></span>
          <%= Enum.at(partners, 0) %>
        </span>
        </figure>
      <% end %>

    </section>
    """
  end
end
