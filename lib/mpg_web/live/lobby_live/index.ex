defmodule MpgWeb.LobbyLive.Index do
  use MpgWeb, :live_view
  alias Mpg.GameSupervisor
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <%= live_redirect "Create Game", to: Routes.live_path(@socket, MpgWeb.GameLive, GameSupervisor.start_game()) %>
    <%= live_redirect "Join Game", to: Routes.lobby_join_path(@socket, :join) %>
    """
  end
end
