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

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       changeset: changeset(),
       player: nil,
       players: [],
       state: nil
     })}
  end

  defp disconnected?(reason) do
    case reason do
      :shutdown -> true
      {:shutdown, shutdown_reason} when shutdown_reason in [:left, :closed] -> true
      _other -> false
    end
  end

  @impl true
  def terminate(reason, %{assigns: %{code: code, player: player}}) do
    if disconnected?(reason) and player do
      code |> Game.drop_player(player.name)
    end
  end

  @impl true
  def handle_params(%{"code" => code}, _url, socket) do
    if !Game.exists(code) do
      raise MpgWeb.GameNotFoundError, "no game found for #{code}"
    end

    if connected?(socket) do
      PubSub.subscribe(Mpg.PubSub, code)
    end

    {:noreply, socket |> assign(code: code)}
  end

  @impl true
  def handle_info({:players, players}, socket) do
    {:noreply, socket |> assign(players: players)}
  end

  @impl true
  def handle_info(:state_changed, %{assigns: %{code: code, player: player}} = socket) do
    state = code |> Game.get_state_for_player(player.name)
    {:noreply, socket |> assign(state: state)}
  end

  @impl true
  def handle_event("validate", %{"player" => params}, socket) do
    {:noreply,
     assign(socket,
       changeset: changeset(params) |> Map.put(:action, :update)
     )}
  end

  def handle_event("save", %{"player" => params}, socket) do
    changeset = changeset(params)

    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, player} ->
        response = socket.assigns.code |> Game.add_player(player.name)

        if response == :player_already_added do
          {:noreply,
           assign(socket,
             changeset:
               changeset
               |> Ecto.Changeset.add_error(:name, "name already taken")
               |> Map.put(:action, :update)
           )}
        else
          {:noreply, assign(socket, player: player)}
        end

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("start", _value, socket) do
    socket.assigns.code |> Game.start()

    {:noreply, socket}
  end

  def handle_event("continue", _value, %{assigns: %{code: code, player: player}} = socket) do
    IO.puts("continue")
    code |> Game.continue(player.name)
    {:noreply, socket}
  end

  def is_creator(players, player) do
    player ==
      players
      |> Enum.reverse()
      |> Enum.at(0)
  end

  @impl true
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
    <% end %>
    <%= if !@state && @player do %>
      <h1 class="text-3xl">Join using code</h1>
      <input disabled class="box-input text-3xl" value={@code}>
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
        <%= if is_creator(@players, @player.name) do %>
          <button phx-click="start" class="btn-action">Start Game</button>
        <% else %>
          <button disabled class="btn-action">Waiting for host to start...</button>
        <% end %>
      </.action_bar>
    <% end %>
    <%= if @state && @player do %>
      <%= if @state.stage == :roles do %>
          <.live_component module={StageRoles} id="roles" state={@state} player_count={length(@players)} />
      <% end %>
      <%= if @state.stage == :player_role do %>
          <.live_component module={StagePlayerRole} id="player_role" role={@code |> Game.get_player_role(@player.name)} />
      <% end %>
      <%= if @state.stage == :werewolf and @state.stage_matches_role do %>
          <.live_component module={StageWerewolf} id="werewolf" code={@code} player_name={@player.name} />
      <% end %>
      <%= if @state.stage == :seer and @state.stage_matches_role do %>
          <.live_component module={StageSeer} id="seer" code={@code} player_name={@player.name} />
      <% end %>
      <%= if @state.stage == :robber and @state.stage_matches_role do %>
          <.live_component module={StageRobber} id="robber" code={@code} player_name={@player.name} />
      <% end %>
      <.action_bar>
        <%= if @state.waiting_on_you do %>
          <button phx-click="continue" class="btn-action">Continue</button>
        <% else %>
          <button disabled class="btn-action">Wait for others...</button>
        <% end %>
      </.action_bar>
    <% end %>
    <pre style="white-space: pre-wrap">
      <%= inspect(@state) %>
    </pre>
    """
  end
end
