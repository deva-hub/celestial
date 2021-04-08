defmodule CelestialPortal.CharacterEntity do
  use GenServer
  import CelestialNetwork.Entity
  alias CelestialNetwork.Socket
  alias CelestialNetwork.Socket.{Message, Broadcast}
  alias Celestial.Metaverse

  def start_link("select", params, %Socket{} = socket) do
    slot = Metaverse.get_slot_by_index!(socket.assigns.current_identity, params.index)

    GenServer.start_link(__MODULE__, {socket, slot.character},
      name: via_tuple(slot.character.id),
      hibernate_after: :timer.minutes(5)
    )
  end

  @impl true
  def init({socket, character}) do
    world_id = Application.fetch_env!(:celestial_portal, :world)
    channel_id = Application.fetch_env!(:celestial_portal, :channel)
    topic = "characters:#{character.id}:worlds:#{world_id}:channels:#{channel_id}"
    socket = %{socket | entity: __MODULE__, entity_pid: self(), topic: topic}
    Phoenix.PubSub.subscribe(Celestial.PubSub, topic)
    state = %{sitting?: false, invisible?: false}
    {:ok, {socket, character, state}, {:continue, {:init, :entity}}}
  end

  @impl true
  def handle_continue({:init, :entity}, {socket, character, state}) do
    push(socket, "c_info", %{
      entity: character,
      group_id: 0,
      family_id: -1,
      family_name: "beta",
      name_color: :white,
      morph: 0,
      invisible?: state.invisible?,
      family_level: -1,
      morph_upgrade: 0,
      arena_winner?: false
    })

    push(socket, "tit", %{
      title: character.class |> to_string |> String.upcase(),
      name: character.name
    })

    push(socket, "fd", %{entity: character})

    push(socket, "lev", %{entity: character, cp: 1})

    push(socket, "at", %{
      id: character.id,
      map: %{id: 1},
      ambiance: %{id: 0},
      position: character.position
    })

    {:noreply, {socket, character, state}, {:continue, {:init, :presence}}}
  end

  def handle_continue({:init, :presence}, {socket, character, state}) do
    presences = CelestialPortal.Presence.list(socket)

    send(self(), %Message{
      event: "presence_diff",
      payload: %{joins: presences}
    })

    CelestialPortal.Presence.track(self(), socket.topic, character.id, %{
      entity: character,
      online_at: inspect(System.system_time(:second))
    })

    {:noreply, {socket, character, state}}
  end

  @impl true
  def handle_info(%Message{event: "walk", payload: payload}, {socket, character, state}) do
    broadcast_from!(socket, "mv", %{
      entity_type: :character,
      entity: character,
      position: payload.position,
      speed: payload.speed
    })

    {:noreply, {socket, character, state}}
  end

  def handle_info(%Broadcast{event: "mv", topic: topic, payload: payload}, {%{topic: topic} = socket, character, state}) do
    push(socket, "mv", payload)
    {:noreply, {socket, character, state}}
  end

  def handle_info(%Message{event: "presence_diff", payload: payload}, {socket, character, state}) do
    for {id, join} <- payload.joins do
      for %{entity: entity} <- join.metas do
        push(socket, "in", %{
          type: :character,
          id: id,
          name_color: :white,
          entity: entity,
          hp_percent: 100,
          mp_percent: 100,
          sitting?: state.sitting?,
          group_id: -1,
          fairy_movement: :neutral,
          fairy_element: :neutral,
          fairy_morph: 0,
          morph: 0,
          weapon_upgrade: 0,
          armor_upgrade: 0,
          family_id: -1,
          family_name: "beta",
          invisible?: state.invisible?,
          morph_upgrade: 0,
          morph_bonus: 0,
          family_level: -1,
          family_icons: "0|0|0",
          size: 10
        })
      end
    end

    {:noreply, {socket, character, state}}
  end

  def via_tuple(id) do
    {:via, Registry, {CelestialPortal.Registry, id}}
  end
end
