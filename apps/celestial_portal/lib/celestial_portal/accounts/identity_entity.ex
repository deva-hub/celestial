defmodule CelestialPortal.IdentityEntity do
  use GenServer
  import CelestialNetwork.Entity
  alias CelestialNetwork.Socket.Message
  alias Celestial.{Accounts, Metaverse}

  def start_link("handoff", _, socket) do
    GenServer.start_link(__MODULE__, {socket, socket.assigns.current_identity},
      name: via_tuple(socket.assigns.current_identity.id),
      hibernate_after: :timer.minutes(5)
    )
  end

  @impl true
  def init({socket, identity}) do
    world_id = Application.fetch_env!(:celestial_portal, :world)
    channel_id = Application.fetch_env!(:celestial_portal, :channel)
    topic = "identities:#{identity.id}:worlds:#{world_id}:channels:#{channel_id}"
    socket = %{socket | entity: __MODULE__, entity_pid: self(), topic: topic}
    Phoenix.PubSub.subscribe(Celestial.PubSub, socket.topic)
    {:ok, {socket, identity}, {:continue, :after_init}}
  end

  @impl true
  def handle_continue(:after_init, {socket, identity}) do
    slots = Metaverse.list_slots(identity)
    push(socket, "clists", %{slots: slots})
    {:noreply, {socket, identity}}
  end

  @impl true
  def handle_info(%Message{event: "char_NEW", payload: payload}, {socket, identity}) do
    case Metaverse.create_slot(identity, payload) do
      {:ok, _} ->
        push(socket, "clists", %{slots: Metaverse.list_slots(identity)})

      {:error, _} ->
        push(socket, "failc", %{error: :unexpected_error})
    end

    {:noreply, {socket, identity}}
  end

  def handle_info(%Message{event: "char_DEL", payload: payload}, {socket, identity}) do
    if Accounts.get_identity_by_username_and_password(identity.username, payload.password) do
      case Metaverse.get_slot_by_index!(identity, payload.index) |> Metaverse.delete_slot() do
        {:ok, _} ->
          push(socket, "clists", %{slots: Metaverse.list_slots(identity)})

        {:error, _} ->
          push(socket, "failc", %{error: :unexpected_error})
      end

      {:noreply, {socket, identity}}
    else
      push(socket, "failc", %{error: :unvalid_credentials})
      {:noreply, {socket, identity}}
    end
  end

  def via_tuple(id) do
    {:via, Registry, {CelestialPortal.Registry, id}}
  end
end
