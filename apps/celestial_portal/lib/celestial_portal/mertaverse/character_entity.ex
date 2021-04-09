defmodule CelestialPortal.CharacterEntity do
  use GenServer
  import CelestialNetwork.Entity
  import CelestialNetwork.Socket
  alias CelestialNetwork.Socket.{Message, Broadcast}
  alias Celestial.Metaverse

  def start_link("select", params, socket) do
    slot = Metaverse.get_slot_by_index!(socket.assigns.current_identity, params.index)

    GenServer.start_link(__MODULE__, {socket, slot.character},
      name: via_tuple(slot.character.id),
      hibernate_after: :timer.minutes(5)
    )
  end

  @impl true
  def init({socket, character}) do
    Phoenix.PubSub.subscribe(Celestial.PubSub, socket.topic)
    socket = %{socket | entity: __MODULE__, entity_pid: self()}
    socket = assign(socket, character: character, sitting?: false, invisible?: false)
    {:ok, socket, {:continue, :after_init}}
  end

  @impl true
  def handle_continue(:after_init, socket) do
    push(socket, "c_info", %{
      entity: socket.assigns.character,
      group_id: 0,
      family_id: -1,
      family_name: "beta",
      name_color: :white,
      morph: 0,
      invisible?: socket.assigns.invisible?,
      family_level: -1,
      morph_upgrade: 0,
      arena_winner?: false
    })

    push(socket, "tit", %{
      title: socket.assigns.character.class |> to_string |> String.upcase(),
      name: socket.assigns.character.name
    })

    push(socket, "fd", %{entity: socket.assigns.character})

    push(socket, "lev", %{entity: socket.assigns.character, cp: 1})

    push(socket, "at", %{
      id: socket.assigns.character.id,
      map: %{id: 1},
      ambiance: %{id: 0},
      position: socket.assigns.character.position
    })

    push_presences(socket, %{joins: CelestialPortal.Presence.list(socket)})

    CelestialPortal.Presence.track(self(), socket.topic, socket.assigns.character.id, %{
      entity: socket.assigns.character,
      online_at: inspect(System.system_time(:second))
    })

    {:noreply, socket}
  end

  @impl true
  def handle_info(%Message{event: "walk", payload: payload}, socket) do
    broadcast_from!(socket, "mv", %{
      entity_type: :character,
      entity: socket.assigns.character,
      position: payload.position,
      speed: payload.speed
    })

    {:noreply, socket}
  end

  def handle_info(%Broadcast{event: "mv", payload: payload}, socket) do
    push(socket, "mv", payload)
    {:noreply, socket}
  end

  def handle_info(%Message{event: "presence_diff", payload: payload}, socket) do
    push_presences(socket, payload)
    {:noreply, socket}
  end

  def push_presences(socket, presences) do
    for {id, join} <- presences.joins do
      for %{entity: entity} <- join.metas do
        push(socket, "in", %{
          type: :character,
          id: id,
          name_color: :white,
          entity: entity,
          hp_percent: 100,
          mp_percent: 100,
          sitting?: socket.assigns.sitting?,
          group_id: -1,
          fairy_movement: :neutral,
          fairy_element: :neutral,
          fairy_morph: 0,
          morph: 0,
          weapon_upgrade: 0,
          armor_upgrade: 0,
          family_id: -1,
          family_name: "beta",
          invisible?: socket.assigns.invisible?,
          morph_upgrade: 0,
          morph_bonus: 0,
          family_level: -1,
          family_icons: "0|0|0",
          size: 10
        })
      end
    end
  end

  def via_tuple(id) do
    {:via, Registry, {CelestialPortal.Registry, id}}
  end
end
