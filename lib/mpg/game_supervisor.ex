defmodule Mpg.GameSupervisor do
  use DynamicSupervisor
  alias Mpg.Game

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(name) do
    DynamicSupervisor.start_child(__MODULE__, {Game, name})
  end

  def start_game() do
    code = Nanoid.generate(4, "23456789ABCDEFGHJKMNPQRSTUVWXYZ")
    start_child(code)
    code
  end
end
