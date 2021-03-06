defmodule MpgWeb.LobbyLive.Index do
  use MpgWeb, :live_view
  alias Mpg.GameSupervisor
  import ActionBar
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <style>
      header {
        background-image: url('/images/splash.png');
        background-position: center -3vh;
        background-size: 72vh;
        background-repeat: no-repeat;
      }
    </style>
    <header class="h-[60vh] w-full">
      <h1 class="text-4xl mt-10 mb-2">One Night Werewolf</h1>
      <h2 class="text-2xl font-normal mt-5 mb-2">Multiplayer Party Game</h2>
    </header>
    <.action_bar>
      <%= live_redirect "Create Game", class: "btn-action", to: Routes.live_path(@socket, MpgWeb.GameLive, GameSupervisor.start_game()) %>
      <%= live_redirect "Join Game", class: "btn-action", to: Routes.lobby_join_path(@socket, :join) %>
    </.action_bar>
    """
  end
end
