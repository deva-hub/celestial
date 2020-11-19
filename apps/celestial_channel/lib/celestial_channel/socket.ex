defmodule CelestialChannel.Socket do
  @moduledoc false
  @behaviour Nostalex.Socket.Transport

  require Logger
  import Nostalex.Socket
  alias Nostalex.Socket.Message
  alias Celestial.{Accounts, Universe}
  alias CelestialChannel.Crypto

  @impl true
  def init(socket) do
    {:ok, assign(socket, %{current_identity: nil, id: nil})}
  end

  @impl true
  def handle_in({payload, opts}, %{key: nil} = socket) do
    msg = payload |> Crypto.decrypt() |> socket.serializer.decode!(opts)
    handle_in(msg, socket)
  end

  def handle_in({payload, opts}, socket) do
    msg = payload |> Crypto.decrypt(socket.key) |> socket.serializer.decode!(opts)
    handle_in(msg, socket)
  end

  def handle_in(%{payload: [id, key]}, %{key: nil} = socket) do
    {:ok, socket |> assign(:id, id) |> put_key(String.to_integer(key))}
  end

  def handle_in(%{payload: [_, email, id, password]}, %{assigns: %{current_identity: nil}} = socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()

    with {:ok, identity} <- get_identity_by_email_and_password(email, password),
         :ok <- consume_identity_otk(identity, address, socket.key) do
      heroes = Universe.list_identity_heroes(identity)

      # TODO: remove placeholder data
      {opcode, payload} =
        encode_reply(socket, %Message{
          event: "clist_start",
          payload: %{length: length(heroes)}
        })

      send(self(), {:socket_push, opcode, payload})

      Enum.each(heroes, fn hero ->
        {opcode, payload} =
          encode_reply(socket, %Message{
            event: "clist",
            payload: %{
              slot: hero.slot,
              name: hero.name,
              gender: hero.gender,
              hair_style: hero.hair_style,
              hair_color: hero.hair_color,
              class: hero.class,
              level: hero.level,
              hero_level: hero.hero_level,
              job_level: hero.job_level,
              pets: [],
              equipment: %{}
            }
          })

        send(self(), {:socket_push, opcode, payload})
      end)

      {opcode, payload} =
        encode_reply(socket, %Message{
          event: "clist_end"
        })

      send(self(), {:socket_push, opcode, payload})

      {:ok, assign(socket, %{current_identity: identity, id: id})}
    else
      :error ->
        {:stop, :normal, socket}
    end
  end

  def handle_in(%{event: "select", payload: payload, id: id}, socket) do
    hero = Universe.get_hero!(payload.slot)

    # TODO: remove placeholder data
    {opcode, paylaod} =
      encode_reply(socket, %Message{
        event: "c_info",
        payload: %{
          name: hero.name,
          group_id: 0,
          family_id: 0,
          family_name: "beta",
          id: hero.id,
          name_color: :white,
          gender: hero.gender,
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
      })

    send(self(), {:socket_push, opcode, paylaod})

    {opcode, paylaod} =
      encode_reply(socket, %Message{
        event: "tit",
        payload: %{
          class: hero.class,
          name: hero.name
        }
      })

    send(self(), {:socket_push, opcode, paylaod})

    {opcode, paylaod} =
      encode_reply(socket, %Message{
        event: "fd",
        payload: %{
          reputation: :beginner,
          dignity: :basic
        }
      })

    send(self(), {:socket_push, opcode, paylaod})

    {opcode, paylaod} =
      encode_reply(socket, %Message{
        event: "lev",
        payload: %{
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
      })

    send(self(), {:socket_push, opcode, paylaod})

    {opcode, paylaod} =
      encode_reply(socket, %Message{
        event: "at",
        payload: %{
          id: hero.id,
          map_id: 1,
          music_id: 0,
          position_x: :rand.uniform(3) + 77,
          position_y: :rand.uniform(4) + 11
        }
      })

    send(self(), {:socket_push, opcode, paylaod})

    {:ok, assign(socket, :id, id)}
  end

  def handle_in(%{event: "0", id: id}, socket) do
    Logger.debug("HEARTBEAT #{id}")
    {:ok, assign(socket, :id, id)}
  end

  def handle_in(data, socket) do
    Logger.debug("GARBAGE #{data.id} #{inspect(data.payload)}")
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

  defp encode_reply(socket, data) do
    {:socket_push, opcode, payload} = socket.serializer.encode!(data)
    {opcode, payload |> Enum.join() |> Crypto.encrypt()}
  end

  defp put_key(socket, key) do
    %{socket | key: key}
  end

  defp get_identity_by_email_and_password(email, password) do
    if identity = Accounts.get_identity_by_email_and_password(email, password) do
      {:ok, identity}
    else
      :error
    end
  end

  defp consume_identity_otk(identity, address, key) do
    case Accounts.consume_identity_otk(address, key) do
      {:ok, %{id: id}} when id == identity.id ->
        :ok

      {:error, _} ->
        :error
    end
  end
end
