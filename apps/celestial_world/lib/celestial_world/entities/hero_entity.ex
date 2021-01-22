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

  def walk(name, coordinates, speed) do
    GenServer.cast(name, {:walk, coordinates, speed})
  end

  @impl true
  def init({socket, hero}) do
    # TODO: Refactory world ID fetching
    Phoenix.PubSub.subscribe(Celestial.PubSub, "worlds:#{socket.assigns.world_id}:channels:#{socket.assigns.channel_id}")
    {:ok, {socket, hero}, {:continue, :contact}}
  end

  @impl true
  def handle_continue(:contact, {socket, hero}) do
    # TODO: remove placeholder data
    push(
      socket,
      "c_info",
      %{
        name: hero.name,
        group_id: 0,
        family_id: -1,
        family_name: "beta",
        id: hero.id,
        name_color: :white,
        sex: hero.sex,
        hair_style: hero.hair_style,
        hair_color: hero.hair_color,
        class: hero.class,
        reputation: :beginner,
        compliment: 0,
        morph: 0,
        invisible?: false,
        family_level: -1,
        morph_upgrade: 0,
        arena_winner?: false
      }
    )

    push(
      socket,
      "tit",
      %{
        title: hero.class |> to_string |> String.upcase(),
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

    coordinates = %{
      x: :rand.uniform(3) + 77,
      y: :rand.uniform(4) + 11
    }

    push(
      socket,
      "at",
      %{
        id: hero.id,
        map_id: 1,
        music_id: 0,
        coordinates: coordinates
      }
    )

    Phoenix.PubSub.broadcast_from!(
      Celestial.PubSub,
      self(),
      "worlds:#{socket.assigns.world_id}:channels:#{socket.assigns.channel_id}",
      {:celestial, :entity_contact, hero.id, coordinates, hero}
    )

    {:noreply, {socket, hero}}
  end

  @impl true
  def handle_cast({:walk, coordinates, _speed}, {socket, hero}) do
    # TODO: Calculate the next position
    Phoenix.PubSub.broadcast_from!(
      Celestial.PubSub,
      self(),
      "worlds:#{socket.assigns.world_id}:channels:#{socket.assigns.channel_id}",
      {:celestial, :entity_move, hero.id, coordinates}
    )

    {:noreply, {socket, hero}}
  end

  @impl true
  def handle_info({:celestial, :entity_move, id, coordinates}, {socket, hero}) do
    {:noreply, {socket, hero}}
  end

  def handle_info({:celestial, :entity_contact, id, coordinates, entity}, {socket, hero}) do
    push(
      socket,
      "in",
      %{
        type: :hero,
        name: entity.name,
        id: id,
        coordinates: coordinates,
        direction: :north,
        name_color: :white,
        sex: entity.sex,
        hair_style: entity.hair_style,
        hair_color: entity.hair_color,
        class: entity.class,
        equipments: %{},
        hp_percent: 100,
        mp_percent: 100,
        sitting?: false,
        group_id: -1,
        fairy_movement: :neutre,
        fairy_element: :neutre,
        fairy_morph: 0,
        morph: 0,
        weapon_upgrade: 0,
        armor_upgrade: 0,
        family_id: -1,
        family_name: "beta",
        reputation: :beginner,
        invisible?: false,
        morph_upgrade: 0,
        faction: :neutre,
        morph_bonus: 0,
        level: entity.level,
        family_level: -1,
        family_icons: "0|0|0",
        compliment: 0,
        size: 10
      }
    )

    {:noreply, {socket, hero}}
  end

  def via_tuple(id) do
    {:via, Registry, {CelestialWorld.Registry, id}}
  end
end
