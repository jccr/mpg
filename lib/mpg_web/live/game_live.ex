defmodule MpgWeb.GameLive do
  use MpgWeb, :live_view
  alias Mpg.Player
  alias Mpg.Game
  import ActionBar

  alias Phoenix.PubSub

  def changeset(params \\ %{}) do
    %Player{}
    |> Player.changeset(params)
  end

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       changeset: changeset(),
       player: nil,
       players: []
     })}
  end

  def handle_params(%{"code" => code}, _url, socket) do
    if !Game.exists(code) do
      raise MpgWeb.GameNotFoundError, "no game found for #{code}"
    end

    PubSub.subscribe(Mpg.PubSub, code)

    {:noreply, socket |> assign(code: code)}
  end

  def handle_info({:players, players}, socket) do
    {:noreply, socket |> assign(players: players)}
  end

  def handle_event("validate", %{"player" => params}, socket) do
    {:noreply,
     assign(socket,
       changeset: changeset(params) |> Map.put(:action, :update)
     )}
  end

  def handle_event("save", %{"player" => params}, socket) do
    case Ecto.Changeset.apply_action(changeset(params), :insert) do
      {:ok, player} ->
        socket.assigns.code |> Game.add_player(player.name)
        {:noreply, assign(socket, player: player)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def is_creator(players, player) do
    player ==
      players
      |> Enum.reverse()
      |> Enum.at(0)
  end

  def render(assigns) do
    ~H"""
    <%= if !@player do %>
      <.form let={f} for={@changeset} phx-change="validate" phx-submit="save" class="w-full">
        <div class="flex flex-col gap-4 h-64">
          <%= label f, :name, "Give yourself a name", class: "text-3xl" %>
          <%= text_input f, :name, [
            class: "box-input text-center text-2xl",
            minlength: 1,
            maxlength: 12,
            autofocus: true,
            autocapitalize: "off",
            autocorrect: "off",
            autocomplete: "off",
            spellcheck: false
            ] %>
          <%= error_tag f, :name %>
        </div>
        <.action_bar>
          <%= submit "Continue", class: "btn-action" %>
        </.action_bar>
      </.form>
    <% else %>
      <h1 class="text-3xl">Join using code</h1>
      <span class="block box-input text-3xl bg-transparent"><%= @code %></span>
      <h1 class="text-3xl mt-2">Who else is here</h1>
      <ol class="list-disc min-h-[40vh] text-left">
        <%= for player <- Enum.reverse(@players) do %>
          <li>
            <span class="text-2xl"><%= player %></span>
            <%= if is_creator(@players, player) do %> (host)<% end %>
          </li>
        <% end %>
      </ol>
      <.action_bar>
        <button phx-click="start" class="btn-action">Start Game</button>
      </.action_bar>
    <% end %>
    """
  end
end
