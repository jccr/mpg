defmodule MpgWeb.LobbyLive.Join do
  use MpgWeb, :live_view
  alias Mpg.Join

  def changeset(params \\ %{}) do
    %Join{}
    |> Join.changeset(params)
  end

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       changeset: changeset()
     })}
  end

  def handle_event("validate", %{"join" => params}, socket) do
    {:noreply,
     assign(socket,
       changeset: changeset(params) |> Map.put(:action, :update)
     )}
  end

  def handle_event("save", %{"join" => params}, socket) do
    case Ecto.Changeset.apply_action(changeset(params), :insert) do
      {:ok, join} ->
        {:noreply,
         push_redirect(socket, to: Routes.live_path(socket, MpgWeb.GameLive, join.code))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def render(assigns) do
    ~H"""
    <.form let={f} for={@changeset} phx-change="validate" phx-submit="save">
    <%= label f, :code %>
    <%= text_input f, :code, [
      minlength: 4,
      maxlength: 4,
      autofocus: true,
      autocapitalize: "characters",
      autocorrect: "off",
      autocomplete: "off",
      spellcheck: false,
      oninput: "let p=this.selectionStart;this.value=this.value.toUpperCase();this.setSelectionRange(p, p);"
      ] %>
    <%= error_tag f, :code %>

    <%= submit "Join" %>
    </.form>
    """
  end
end
