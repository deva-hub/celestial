defmodule CelestialWorld.HeroEntity do
  use GenServer

  import Nostalex.Entity
  alias Nostalex.Socket
  alias Nostalex.Socket.{Message, Broadcast}

  def start_link(%Socket{} = socket, hero) do
    GenServer.start_link(__MODULE__, {socket, hero},
      name: via_tuple(hero.id),
      hibernate_after: :timer.minutes(5)
    )
  end

  @impl true
  def init({socket, hero}) do
    Phoenix.PubSub.subscribe(Celestial.PubSub, socket.topic)

    socket = %{
      socket
      | entity: __MODULE__,
        entity_pid: self()
    }

    {:ok, {socket, hero}, {:continue, {:init, :entity}}}
  end

  @impl true
  def handle_continue({:init, :entity}, {socket, hero}) do
    push(socket, "c_info", %{
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
    })

    push(socket, "tit", %{
      title: hero.class |> to_string |> String.upcase(),
      name: hero.name
    })

    push(socket, "fd", %{
      reputation: :beginner,
      dignity: :basic
    })

    push(socket, "lev", %{
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
    })

    push(socket, "at", %{
      id: hero.id,
      map_id: 1,
      music_id: 0,
      coordinate_x: hero.position.coordinate_x,
      coordinate_y: hero.position.coordinate_y
    })

    {:noreply, {socket, hero}, {:continue, {:init, :presence}}}
  end

  def handle_continue({:init, :presence}, {socket, hero}) do
    presences = CelestialWorld.Presence.list(socket)

    send(self(), %Message{
      event: "presence_diff",
      payload: %{joins: presences}
    })

    CelestialWorld.Presence.track(self(), socket.topic, hero.id, %{
      entity: hero,
      online_at: inspect(System.system_time(:second))
    })

    {:noreply, {socket, hero}}
  end

  @impl true
  def handle_info(%Message{event: "walk", payload: payload}, {socket, hero}) do
    broadcast_from!(socket, "mv", %{
      entity_type: :hero,
      entity_id: hero.id,
      coordinate_x: payload.coordinate_x,
      coordinate_y: payload.coordinate_y,
      speed: payload.speed
    })

    {:noreply, {socket, hero}}
  end

  def handle_info(%Broadcast{event: "mv", topic: topic, payload: payload}, {%{topic: topic} = socket, hero}) do
    push(socket, "mv", payload)
    {:noreply, {socket, hero}}
  end

  def handle_info(%Message{event: "presence_diff", payload: payload}, {socket, hero}) do
    for {id, join} <- payload.joins do
      for meta <- join.metas do
        %{entity: entity} = meta

        push(socket, "in", %{
          type: :hero,
          name: entity.name,
          id: id,
          coordinate_x: entity.position.coordinate_x,
          coordinate_y: entity.position.coordinate_y,
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
        })
      end
    end

    {:noreply, {socket, hero}}
  end

  def via_tuple(id) do
    {:via, Registry, {CelestialWorld.Registry, id}}
  end
end
