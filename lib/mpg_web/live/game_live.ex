defmodule MpgWeb.GameLive do
  use MpgWeb, :live_view
  alias Mpg.Player
  alias Mpg.Game

  def changeset(params \\ %{}) do
    %Player{}
    |> Player.changeset(params)
  end

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       changeset: changeset(),
       player: nil
     })}
  end

  def handle_params(%{"code" => code}, _url, socket) do
    if !Game.exists(code) do
      raise MpgWeb.GameNotFoundError, "no game found for #{code}"
    end

    {:noreply, socket |> assign(code: code)}
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

  def render(assigns) do
    ~H"""
    <%= if !@player do %>
      <.form let={f} for={@changeset} phx-change="validate" phx-submit="save">
        <%= label f, :name %>
        <%= text_input f, :name, [
          minlength: 1,
          maxlength: 12,
          autofocus: true,
          autocapitalize: "off",
          autocorrect: "off",
          autocomplete: "off",
          spellcheck: false
          ] %>
        <%= error_tag f, :name %>

        <%= submit "Save" %>
      </.form>
    <% else %>
      Welcome, <%= @player.name %>
    <% end %>
    <div>
      <h1>Join using code: <%= @code %></h1>
    </div>
    """
  end
end
