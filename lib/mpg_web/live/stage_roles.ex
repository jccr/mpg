defmodule StageRoles do
  use MpgWeb, :live_component
  alias Mpg.Game

  def render(assigns) do
    ~H"""
    <section class="inline-block">
      <h1 class="text-3xl">Roles</h1>
      <p>We've spotted these characters roaming around the town!</p>
      <p>Some of them could show up tonight...</p>
      <figure class="flex flex-col mt-6">
      <%= for role <- Game.role_sets(@player_count) do %>
      <span class="box capitalize text-xl flex items-center justify-center gap-4">
        <span class="text-3xl"><%= Game.role_cards[role] %></span>
        <%= Atom.to_string(role) %>
      </span>
      <% end %>
      </figure>
    </section>
    """
  end
end
