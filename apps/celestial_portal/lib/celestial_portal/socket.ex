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
      hero_pid: nil,
      last_message_id: nil
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

  def handle_in(%{payload: [id, key]}, %{key: nil} = socket) do
    {:ok, socket |> assign(:last_message_id, id) |> put_key(String.to_integer(key))}
  end

  def handle_in(%{payload: [_, username, id, password]}, %{assigns: %{current_identity: nil}} = socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()

    with {:ok, identity} <- get_identity_by_username_and_password(username, password),
         :ok <- consume_identity_otk(identity, address, socket.key) do
      push_heroes(self(), Galaxy.list_heroes(identity), socket.serializer)
      {:ok, assign(socket, %{current_identity: identity, id: id})}
    else
      :error ->
        {:stop, :normal, socket}
    end
  end

  def handle_in(%{event: "select", payload: payload, id: id}, socket) do
    hero = Galaxy.get_hero_by_slot!(socket.assigns.current_identity, payload.slot)

    {:ok, hero_pid} = CelestialWorld.EntitySupervisor.start_hero(hero)

    # TODO: remove placeholder data
    push(
      self(),
      "c_info",
      %{
        name: hero.name,
        group_id: 0,
        family_id: 0,
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
        family_level: 1,
        morph_upgrade?: false,
        arena_winner?: false
      },
      socket.serializer
    )

    push(
      self(),
      "tit",
      %{
        class: hero.class,
        name: hero.name
      },
      socket.serializer
    )

    push(
      self(),
      "fd",
      %{
        reputation: :beginner,
        dignity: :basic
      },
      socket.serializer
    )

    push(
      self(),
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
      },
      socket.serializer
    )

    push(
      self(),
      "at",
      %{
        id: hero.id,
        map_id: 1,
        music_id: 0,
        axis: %{
          x: :rand.uniform(3) + 77,
          y: :rand.uniform(4) + 11
        }
      },
      socket.serializer
    )

    {:ok, assign(socket, %{last_message_id: id, hero_pid: hero_pid})}
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
    HeroEntity.walk(socket.assigns.hero_pid, payload.axis, payload.speed)
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
          equipment: %{}
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

  defp consume_identity_otk(identity, address, key) do
    case Accounts.consume_identity_otk(address, key) do
      {:ok, %{id: id}} when id == identity.id ->
        :ok

      :error ->
        :error
    end
  end
end
