defmodule CelestialPortal.Socket do
  @moduledoc false
  @behaviour Nostalex.Socket.Transport

  require Logger
  import Nostalex.Socket
  alias Nostalex.Socket.Message
  alias Celestial.{Accounts, Galaxy}
  alias CelestialPortal.Crypto

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

  def handle_in(%{payload: [_, username, id, password]}, %{assigns: %{current_identity: nil}} = socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()

    with {:ok, identity} <- get_identity_by_username_and_password(username, password),
         :ok <- consume_identity_otk(identity, address, socket.key) do
      heroes = Galaxy.list_heroes(identity)

      # TODO: remove placeholder data
      push(self(), "clist_start", %{length: length(heroes)}, socket.serializer)

      Enum.each(heroes, fn hero ->
        push(
          self(),
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
          socket.serializer
        )
      end)

      push(self(), "clist_end", %{}, socket.serializer)

      {:ok, assign(socket, %{current_identity: identity, id: id})}
    else
      :error ->
        {:stop, :normal, socket}
    end
  end

  def handle_in(%{event: "select", payload: payload, id: id}, socket) do
    hero = Galaxy.get_hero_by_slot!(socket.assigns.current_identity, payload.slot)

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
        position_x: :rand.uniform(3) + 77,
        position_y: :rand.uniform(4) + 11
      },
      socket.serializer
    )

    {:ok, assign(socket, :id, id)}
  end

  def handle_in(%{event: "Char_NEW", payload: payload}, socket) do
    case Galaxy.create_hero(socket.assigns.current_identity, payload) do
      {:ok, _} ->
        heroes = Galaxy.list_heroes(socket.assigns.current_identity)

        # TODO: remove placeholder data
        push(self(), "clist_start", %{length: length(heroes)}, socket.serializer)

        Enum.each(heroes, fn hero ->
          push(
            self(),
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
            socket.serializer
          )
        end)

        push(self(), "clist_end", %{}, socket.serializer)

        :ok

      {:error, _} ->
        push(self(), "failc", %{error: :unexpected_error}, socket.serializer)
    end

    {:ok, socket}
  end

  def handle_in(%{event: "Char_DEL", payload: payload}, socket) do
    case get_identity_by_username_and_password(socket.assigns.current_identity.username, payload.password) do
      {:ok, identity} ->
        hero = Galaxy.get_hero_by_slot!(socket.assigns.current_identity, payload.slot)

        case Galaxy.delete_hero(hero) do
          {:ok, _} ->
            heroes = Galaxy.list_heroes(socket.assigns.current_identity)

            # TODO: remove placeholder data
            push(self(), "clist_start", %{length: length(heroes)}, socket.serializer)

            Enum.each(heroes, fn hero ->
              push(
                self(),
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
                socket.serializer
              )
            end)

            push(self(), "clist_end", %{}, socket.serializer)

            {:ok, assign(socket, :current_identity, identity)}

          {:error, _} ->
            push(self(), "failc", %{error: :unexpected_error}, socket.serializer)
            {:ok, socket}
        end

      {:error, _} ->
        push(self(), "failc", %{error: :unvalid_credentials}, socket.serializer)
        {:ok, socket}
    end
  end

  def handle_in(%{event: "0", id: id}, socket) do
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

  defp push(pid, event, payload, serializer) do
    message = %Message{event: event, payload: payload}
    send(pid, serializer.encode!(message))
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
