defmodule CelestialWorld.Channel do
  @moduledoc false
  use Nostalex.Channel

  require Logger
  alias Celestial.{Accounts, World}

  @impl true
  def init(socket) do
    {:ok, assign(socket, %{current_identity: nil, packet_id: nil})}
  end

  @impl true
  def handle_packet({:upgrade, id}, socket) do
    {:ok, assign(socket, :id, id)}
  end

  def handle_packet({:dynamic, [_, email, packet_id, password]}, %{assigns: %{current_identity: nil}} = socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()

    with {:ok, identity} <- get_identity_by_email_and_password(email, password),
         :ok <- consume_identity_one_time_key(identity, address, socket.key) do
      heroes = World.list_identity_heroes(identity)

      # TODO: remove placeholder data
      heroes =
        Enum.map(heroes, fn hero ->
          %{
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
        end)

      {:reply, :ok, {:clist, heroes}, assign(socket, %{current_identity: identity, packet_id: packet_id})}
    else
      :error ->
        {:stop, :normal, socket}
    end
  end

  def handle_packet({:select, packet_id, slot}, socket) do
    hero = World.get_hero!(slot)

    # TODO: remove placeholder data
    send(
      self(),
      {:socket_push,
       {:c_info,
        %{
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
        }}}
    )

    send(
      self(),
      {:socket_push,
       {:tit,
        %{
          class: hero.class,
          name: hero.name
        }}}
    )

    send(
      self(),
      {:socket_push,
       {:fd,
        %{
          reputation: :beginner,
          dignity: :basic
        }}}
    )

    send(
      self(),
      {:socket_push,
       {:lev,
        %{
          level: hero.level,
          job_level: hero.job_level,
          job_xp: hero.job_xp,
          xp_max: 10000,
          job_xp_max: 10000,
          reputation: :beginner,
          cp: 1,
          hero_xp: hero.xp,
          hero_level: hero.hero_level,
          hero_xp_max: 10000
        }}}
    )

    send(
      self(),
      {:socket_push,
       {:at,
        %{
          id: hero.id,
          map_id: 1,
          music_id: 0,
          position_x: :rand.uniform(3) + 77,
          position_y: :rand.uniform(4) + 11
        }}}
    )

    {:ok, assign(socket, :packet_id, packet_id)}
  end

  def handle_packet({:heartbeat, packet_id}, socket) do
    Logger.debug(["HEARTBEAT ", packet_id])
    {:ok, assign(socket, :packet_id, packet_id)}
  end

  def handle_packet(data, socket) do
    Logger.debug(["GARBAGE ", inspect(data)])
    {:ok, socket}
  end

  defp get_identity_by_email_and_password(email, password) do
    if identity = Accounts.get_identity_by_email_and_password(email, password) do
      {:ok, identity}
    else
      :error
    end
  end

  defp consume_identity_one_time_key(identity, address, key) do
    case Accounts.consume_identity_one_time_key(address, key) do
      {:ok, %{id: id}} when id == identity.id ->
        :ok

      {:error, _} ->
        :error
    end
  end
end
