defmodule CelestialPortal.Manager do
  use GenServer

  alias CelestialPortal.Presence

  @default_capacity 2_147_483_647

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    id = Keyword.fetch!(opts, :id)
    world_id = Keyword.fetch!(opts, :world_id)
    world_name = Keyword.fetch!(opts, :world_name)
    port = Keyword.fetch!(opts, :port)
    hostname = Keyword.fetch!(opts, :hostname)
    capacity = Keyword.get(opts, :capacity, @default_capacity)

    Presence.track(self(), "channels", id, %{
      world_id: world_id,
      world_name: world_name,
      hostname: hostname,
      port: port,
      population: 0,
      capacity: capacity,
      online_at: inspect(System.system_time(:second))
    })

    {:ok, opts}
  end
end
