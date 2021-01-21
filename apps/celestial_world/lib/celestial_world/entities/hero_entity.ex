defmodule CelestialWorld.HeroEntity do
  use GenServer

  import CelestialWorld.Entity
  alias Nostalex.Socket

  def start_link(%Socket{} = socket, hero) do
    GenServer.start_link(__MODULE__, {socket, hero},
      name: via_tuple(hero.id),
      hibernate_after: :timer.minutes(5)
    )
  end

  def walk(name, axis, speed) do
    GenServer.cast(name, {:walk, axis, speed})
  end

  @impl true
  def init({socket, hero}) do
    # TODO: Refactory world ID fetching
    world = Application.fetch_env!(:celestial_world, :id)
    Phoenix.PubSub.subscribe(Celestial.PubSub, "worlds:#{world}")
    {:ok, {socket, hero}, {:continue, :contact}}
  end

  @impl true
  def handle_continue(:contact, {socket, hero}) do
    world = Application.fetch_env!(:celestial_world, :id)

    Phoenix.PubSub.broadcast!(
      Celestial.PubSub,
      "worlds:#{world}",
      {:celestial, :entity_contact, hero.id, hero}
    )

    Phoenix.PubSub.broadcast!(
      Celestial.PubSub,
      "worlds:#{world}",
      {:celestial, :entity_walk, hero.id,
       %{
         x: :rand.uniform(3) + 77,
         y: :rand.uniform(4) + 11
       }}
    )

    {:noreply, {socket, hero}}
  end

  @impl true
  def handle_cast({:walk, axis, _speed}, {socket, hero}) do
    world = Application.fetch_env!(:celestial_world, :id)

    # TODO: Calculate the next position
    Phoenix.PubSub.broadcast_from!(
      Celestial.PubSub,
      self(),
      "worlds:#{world}",
      {:celestial, :entity_walk, hero.id, axis}
    )

    {:noreply, {socket, hero}}
  end

  @impl true
  def handle_info({:celestial, :entity_walk, id, axis}, {socket, hero}) do
    push(
      socket,
      "at",
      %{
        id: id,
        map_id: 1,
        music_id: 0,
        axis: axis
      }
    )

    {:noreply, {socket, hero}}
  end

  def handle_info({:celestial, :entity_contact, id, hero}, {socket, hero}) do
    # TODO: remove placeholder data
    push(
      socket,
      "c_info",
      %{
        name: hero.name,
        group_id: 0,
        family_id: 0,
        family_name: "beta",
        id: id,
        name_color: :white,
        sex: hero.sex,
        hair_style: hero.hair_style,
        hair_color: hero.hair_color,
        class: hero.class,
        reputation: :beginner,
        compliment: 0,
        morph: 0,
        invisible?: false,
        family_level: 1,
        morph_upgrade?: false,
        arena_winner?: false
      }
    )

    push(
      socket,
      "tit",
      %{
        class: hero.class,
        name: hero.name
      }
    )

    push(
      socket,
      "fd",
      %{
        reputation: :beginner,
        dignity: :basic
      }
    )

    push(
      socket,
      "lev",
      %{
        level: hero.level,
        job_level: hero.job_level,
        job_xp: hero.job_xp,
        xp_max: 10_000,
        job_xp_max: 10_000,
        reputation: :beginner,
        cp: 1,
        hero_xp: hero.xp,
        hero_level: hero.hero_level,
        hero_xp_max: 10_000
      }
    )

    {:noreply, {socket, hero}}
  end

  def via_tuple(id) do
    {:via, Registry, {CelestialWorld.Registry, id}}
  end
end
