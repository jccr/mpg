defmodule StageConclusion do
  use MpgWeb, :live_component
  alias Mpg.Game

  def render(assigns) do
    %{player_cards: player_cards} = assigns.code |> Game.get_internal_state()

    ~H"""
    <section class="inline-block">
      <h1 class="text-3xl mb-6">The big reveal!</h1>
      <p>Here are all the final player's roles...</p>
      <figure class="flex flex-col mt-6">
      <%= for {player, role} <- player_cards do %>
      <span class="box text-xl flex items-center justify-center gap-4">
        <span class="text-3xl"><%= Game.role_cards[role] %></span>
        <%= player %>
      </span>
      <% end %>
      </figure>
    </section>
    """
  end
end
