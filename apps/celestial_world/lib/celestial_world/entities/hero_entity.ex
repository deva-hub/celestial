defmodule CelestialWorld.HeroEntity do
  use GenServer

  alias Celestial.Galaxy.Hero

  def start_link(%Hero{} = hero) do
    GenServer.start_link(__MODULE__, hero, name: via_tuple(hero.id))
  end

  @impl true
  def init(hero) do
    {:ok, hero}
  end

  def via_tuple(id) do
    {:via, Registry, {CelestialWorld.Registry, id}}
  end
end
