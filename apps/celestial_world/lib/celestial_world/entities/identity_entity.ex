defmodule CelestialWorld.IdentityEntity do
  use GenServer
  import CelestialNetwork.Socket
  import CelestialNetwork.Entity
  alias CelestialNetwork.Socket
  alias CelestialNetwork.Socket.Message
  alias Celestial.{Accounts, Galaxy}

  def start_link(%Socket{} = socket, identity) do
    GenServer.start_link(__MODULE__, {socket, identity},
      name: via_tuple(identity.id),
      hibernate_after: :timer.minutes(5)
    )
  end

  @impl true
  def init({socket, identity}) do
    Phoenix.PubSub.subscribe(Celestial.PubSub, socket.topic)
    socket = %{socket | entity: __MODULE__, entity_pid: self()}
    {:ok, {socket, identity}, {:continue, :after_init}}
  end

  @impl true
  def handle_continue(:after_init, {socket, identity}) do
    slots = Galaxy.list_slots(identity)
    push(socket, "clists", slots)
    {:noreply, {socket, identity}}
  end

  @impl true
  def handle_info(%Message{event: "select", payload: payload}, {socket, identity}) do
    slot = Galaxy.get_slot_by_index!(socket.assigns.current_identity, payload.index)
    topic = "worlds:#{socket.assigns.world_id}:channels:#{socket.assigns.channel_id}"
    {:ok, _} = CelestialNetwork.EntitySupervisor.start_character(%{socket | topic: topic}, slot.character)
    {:noreply, {socket, identity}}
  end

  def handle_info(%Message{event: "Char_NEW", payload: payload}, {socket, identity}) do
    %{current_identity: current_identity} = socket.assigns

    case Galaxy.create_slot(current_identity, payload) do
      {:ok, _} ->
        push(socket, "clists", Galaxy.list_slots(current_identity))

      {:error, _} ->
        push(socket, "failc", %{error: :unexpected_error})
    end

    {:noreply, {socket, identity}}
  end

  def handle_info(%Message{event: "Char_DEL", payload: payload}, socket) do
    %{current_identity: current_identity} = socket.assigns

    if identity = Accounts.get_identity_by_username_and_password(current_identity.username, payload.password) do
      case Galaxy.get_slot_by_index!(current_identity, payload.index) |> Galaxy.delete_slot() do
        {:ok, _} ->
          :ok

        {:error, _} ->
          push(socket, "failc", %{error: :unexpected_error})
      end

      push(socket, "clists", Galaxy.list_slots(current_identity))

      {:ok, assign(socket, :current_identity, identity)}
    else
      push(socket, "failc", %{error: :unvalid_credentials})
      {:ok, socket}
    end
  end

  def via_tuple(id) do
    {:via, Registry, {CelestialWorld.Registry, id}}
  end
end
