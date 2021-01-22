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
    {:ok, socket |> assign(:last_message_id, id) |> put_key(0)}
  end

  def handle_in(%{payload: [_, key, id, username]}, %{assigns: %{current_identity: nil}} = socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()

    with {:ok, %{username: ^username} = identity} <- Accounts.consume_identity_key(address, key) do
      push_heroes(self(), Galaxy.list_heroes(identity), socket.serializer)
      {:ok, assign(socket, %{current_identity: identity, id: id})}
    else
      :error ->
        {:stop, :normal, socket}
    end
  end

  def handle_in(%{event: "select", payload: payload, id: id}, socket) do
    hero = Galaxy.get_hero_by_slot!(socket.assigns.current_identity, payload.slot)
    topic = "worlds:#{socket.assigns.world_id}:channels:#{socket.assigns.channel_id}"
    {:ok, entity_pid} = Nostalex.EntitySupervisor.start_hero(%{socket | topic: topic}, hero)
    {:ok, assign(socket, %{last_message_id: id, entity_pid: entity_pid})}
  end

  def handle_in(%{event: "Char_NEW", payload: payload}, socket) do
    case Galaxy.create_hero(socket.assigns.current_identity, payload) do
      {:ok, _} ->
        push_heroes(self(), Galaxy.list_heroes(socket.assigns.current_identity), socket.serializer)

      {:error, _} ->
        push(self(), "failc", %{error: :unexpected_error}, socket.serializer)
    end

    {:ok, socket}
  end

  def handle_in(%{event: "Char_DEL", payload: payload}, socket) do
    with {:ok, identity} <- get_identity_by_username_and_password(socket.assigns.current_identity.username, payload.password),
         hero when is_struct(hero) <- Galaxy.get_hero_by_slot!(socket.assigns.current_identity, payload.slot),
         {:ok, _} <- Galaxy.delete_hero(hero) do
      push_heroes(self(), Galaxy.list_heroes(socket.assigns.current_identity), socket.serializer)
      {:ok, assign(socket, :current_identity, identity)}
    else
      {:error, _} ->
        push(self(), "failc", %{error: :unvalid_credentials}, socket.serializer)
        {:ok, socket}
    end
  end

  def handle_in(%{event: "walk", id: id, payload: payload}, socket) do
    HeroEntity.walk(socket.assigns.entity_pid, payload.coordinates, payload.speed)
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
  defp push_heroes(pid, heroes, serializer) do
    push(pid, "clist_start", %{length: length(heroes)}, serializer)

    Enum.each(heroes, fn hero ->
      push(
        pid,
        "clist",
        %{
          slot: hero.slot,
          name: hero.name,
          sex: hero.sex,
          hair_style: hero.hair_style,
          hair_color: hero.hair_color,
          class: hero.class,
          level: hero.level,
          hero_level: hero.hero_level,
          job_level: hero.job_level,
          pets: [],
          equipments: %{}
        },
        serializer
      )
    end)

    push(pid, "clist_end", %{}, serializer)

    :ok
  end

  defp put_key(socket, key) do
    %{socket | key: key}
  end

  defp get_identity_by_username_and_password(username, password) do
    if identity = Accounts.get_identity_by_username_and_password(username, password) do
      {:ok, identity}
    else
      :error
    end
  end
end
