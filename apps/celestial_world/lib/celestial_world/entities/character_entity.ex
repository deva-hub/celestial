defmodule CelestialWorld.CharacterEntity do
  use GenServer

  import Nostalex.Entity
  alias Nostalex.Socket
  alias Nostalex.Socket.{Message, Broadcast}

  def start_link(%Socket{} = socket, character) do
    GenServer.start_link(__MODULE__, {socket, character},
      name: via_tuple(character.id),
      hibernate_after: :timer.minutes(5)
    )
  end

  @impl true
  def init({socket, character}) do
    Phoenix.PubSub.subscribe(Celestial.PubSub, socket.topic)
    socket = %{socket | entity: __MODULE__, entity_pid: self()}
    {:ok, {socket, character}, {:continue, {:init, :entity}}}
  end

  @impl true
  def handle_continue({:init, :entity}, {socket, character}) do
    push(socket, "c_info", %{
      entity: character,
      group_id: 0,
      family_id: -1,
      family_name: "beta",
      name_color: :white,
      reputation: :beginner,
      compliment: 0,
      morph: 0,
      invisible?: false,
      family_level: -1,
      morph_upgrade: 0,
      arena_winner?: false
    })

    push(socket, "tit", %{
      title: character.class |> to_string |> String.upcase(),
      name: character.name
    })

    push(socket, "fd", %{
      reputation: :beginner,
      dignity: :basic
    })

    push(socket, "lev", %{
      entity: character,
      reputation: :beginner,
      cp: 1
    })

    push(socket, "at", %{
      id: character.id,
      map: %{id: 1},
      ambiance: %{id: 0},
      position: character.position
    })

    {:noreply, {socket, character}, {:continue, {:init, :presence}}}
  end

  def handle_continue({:init, :presence}, {socket, character}) do
    presences = CelestialWorld.Presence.list(socket)

    send(self(), %Message{
      event: "presence_diff",
      payload: %{joins: presences}
    })

    CelestialWorld.Presence.track(self(), socket.topic, character.id, %{
      entity: character,
      online_at: inspect(System.system_time(:second))
    })

    {:noreply, {socket, character}}
  end

  @impl true
  def handle_info(%Message{event: "walk", payload: payload}, {socket, character}) do
    broadcast_from!(socket, "mv", %{
      entity_type: :character,
      entity: character,
      position: payload.position,
      speed: payload.speed
    })

    {:noreply, {socket, character}}
  end

  def handle_info(%Broadcast{event: "mv", topic: topic, payload: payload}, {%{topic: topic} = socket, character}) do
    push(socket, "mv", payload)
    {:noreply, {socket, character}}
  end

  def handle_info(%Message{event: "presence_diff", payload: payload}, {socket, character}) do
    for {id, join} <- payload.joins do
      for %{entity: entity} <- join.metas do
        push(socket, "in", %{
          type: :character,
          id: id,
          direction: :north,
          name_color: :white,
          entity: entity,
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
          family_level: -1,
          family_icons: "0|0|0",
          compliment: 0,
          size: 10
        })
      end
    end

    {:noreply, {socket, character}}
  end

  def via_tuple(id) do
    {:via, Registry, {CelestialWorld.Registry, id}}
  end
end
