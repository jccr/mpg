defmodule MpgWeb.LobbyLive.Join do
  use MpgWeb, :live_view
  alias Mpg.Join
  import ActionBar

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
      <div class="flex flex-col gap-4 h-64">
        <%= label f, :code, "Join a game with this code", class: "text-2xl" %>
        <%= text_input f, :code, [
          class: "box-input text-center text-2xl",
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
      </div>
      <.action_bar>
        <%= submit "Join",class: "btn-action" %>
      </.action_bar>
    </.form>
    """
  end
end
