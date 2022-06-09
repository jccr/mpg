defmodule StagePlayerRole do
  use MpgWeb, :live_component
  alias Mpg.Game

  def render(assigns) do
    ~H"""
    <section class="inline-block">
      <h1 class="text-3xl">Your Role</h1>
      <p>You're hiding the fact that you are a...</p>
      <figure class="flex flex-col mt-6">
      <span class="box capitalize text-xl flex items-center justify-center gap-4">
        <span class="text-6xl"><%= Game.role_cards[@role] %></span>
        <%= Atom.to_string(@role) %>
      </span>
      </figure>
    </section>
    """
  end
end
