defmodule CelestialWorld.HeroEntity do
  use GenServer

  alias Celestial.Galaxy.Hero

  def walk(name, axis, speed) do
    GenServer.cast(name, {:walk, axis, speed})
  end

  def start_link(%Hero{} = hero) do
    GenServer.start_link(__MODULE__, hero, name: via_tuple(hero.id))
  end

  @impl true
  def init(hero) do
    {:ok, hero}
  end

  @impl true
  def handle_cast({:walk, axis, speed}, state) do
    # TODO: make use of walk info
    IO.inspect(axis)
    IO.inspect(speed)
    {:noreply, state}
  end

  def via_tuple(id) do
    {:via, Registry, {CelestialWorld.Registry, id}}
  end
end
