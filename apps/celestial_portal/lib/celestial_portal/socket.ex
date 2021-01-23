defmodule CelestialPortal.Socket do
  @moduledoc false
  @behaviour Nostalex.Socket.Transport

  require Logger
  import Nostalex.Socket
  alias Nostalex.Socket.Message
  alias Celestial.{Accounts, Galaxy}
  alias CelestialWorld.HeroEntity

  @impl true
  def init(socket) do
    state = %{
      current_identity: nil,
      entity_pid: nil,
      last_message_id: nil,
      world_id: Application.fetch_env!(:celestial_portal, :world),
      channel_id: Application.fetch_env!(:celestial_portal, :channel)
    }

    {:ok, assign(socket, state)}
  end

  @impl true
  def handle_in({payload, opts}, %{key: nil} = socket) do
    handle_in(socket.serializer.decode!(payload, opts), socket)
  end

  def handle_in({payload, opts}, socket) do
    decode_opts = Keyword.put(opts, :key, socket.key)
    handle_in(socket.serializer.decode!(payload, decode_opts), socket)
  end

  def handle_in(%{id: id}, %{key: nil} = socket) do
    {:ok, %{assign(socket, :last_message_id, id) | key: 0}}
  end

  def handle_in(%{payload: [_, key, id, username]}, %{assigns: %{current_identity: nil}} = socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()

    with {:ok, %{username: ^username} = identity} <- Accounts.consume_identity_key(address, key) do
      push_slots(self(), Galaxy.list_slots(identity), socket.serializer)
      {:ok, assign(socket, %{current_identity: identity, id: id})}
    else
      :error ->
        {:stop, :normal, socket}
    end
  end

  def handle_in(%{event: "select", payload: payload, id: id}, socket) do
    %{current_identity: current_identity} = socket.assigns
    %{index: index} = payload
    slot = Galaxy.get_slot_by_index!(current_identity, index)
    topic = "worlds:#{socket.assigns.world_id}:channels:#{socket.assigns.channel_id}"
    {:ok, entity_pid} = Nostalex.EntitySupervisor.start_hero(%{socket | topic: topic}, slot.hero)
    {:ok, assign(socket, %{last_message_id: id, entity_pid: entity_pid})}
  end

  def handle_in(%{event: "Char_NEW", payload: payload}, socket) do
    %{current_identity: current_identity} = socket.assigns

    attrs = %{
      name: payload.name,
      sex: payload.sex,
      hair_style: payload.hair_style,
      hair_color: payload.hair_color,
      slot: %{
        index: payload.index,
        identity_id: current_identity.id
      }
    }

    case Galaxy.create_hero(attrs) do
      {:ok, _} ->
        push_slots(self(), Galaxy.list_slots(current_identity), socket.serializer)

      {:error, _} ->
        push(self(), "failc", %{error: :unexpected_error}, socket.serializer)
    end

    {:ok, socket}
  end

  def handle_in(%{event: "Char_DEL", payload: payload}, socket) do
    %{password: password, index: index} = payload
    %{current_identity: current_identity} = socket.assigns

    if identity = Accounts.get_identity_by_username_and_password(current_identity.username, password) do
      case Galaxy.get_slot_by_index!(current_identity, index) |> Galaxy.delete_hero() do
        {:ok, _} ->
          :ok

        {:error, _} ->
          push(self(), "failc", %{error: :unexpected_error}, socket.serializer)
      end

      push_slots(self(), Galaxy.list_slots(current_identity), socket.serializer)

      {:ok, assign(socket, :current_identity, identity)}
    else
      push(self(), "failc", %{error: :unvalid_credentials}, socket.serializer)
      {:ok, socket}
    end
  end

  def handle_in(%{event: "walk", id: id, payload: payload}, socket) do
    %{positions: positions, speed: speed} = payload
    %{entity_pid: entity_pid} = socket.assigns
    HeroEntity.walk(entity_pid, positions, speed)
    {:ok, assign(socket, :last_message_id, id)}
  end

  def handle_in(%{event: "0", id: id}, socket) do
    {:ok, assign(socket, :last_message_id, id)}
  end

  def handle_in(data, socket) do
    Logger.debug("GARBAGE id=\"#{data.id}\" event=\"#{data.event}\"\n#{inspect(data.payload)}")
    {:ok, socket}
  end

  @impl true
  def handle_info({:socket_push, opcode, payload}, socket) do
    {:push, {opcode, payload}, socket}
  end

  def handle_info(_, socket) do
    {:ok, socket}
  end

  @impl true
  def terminate(_, _) do
    :ok
  end

  defp push(pid, event, payload, serializer) do
    message = %Message{event: event, payload: payload}
    send(pid, serializer.encode!(message))
    :ok
  end

  # TODO: remove placeholder data
  defp push_slots(pid, slots, serializer) do
    push(pid, "clist_start", %{length: length(slots)}, serializer)

    for slot <- slots do
      push(
        pid,
        "clist",
        %{
          index: slot.index,
          name: slot.hero.name,
          sex: slot.hero.sex,
          hair_style: slot.hero.hair_style,
          hair_color: slot.hero.hair_color,
          class: slot.hero.class,
          level: slot.hero.level,
          hero_level: slot.hero.hero_level,
          job_level: slot.hero.job_level,
          pets: [],
          equipments: %{}
        },
        serializer
      )
    end

    push(pid, "clist_end", %{}, serializer)

    :ok
  end
end
