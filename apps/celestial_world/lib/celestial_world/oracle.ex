defmodule CelestialWorld.Oracle do
  def list_channels do
    [
      %{
        id: 1,
        world_id: 2,
        slot: 100,
        ip: {172, 30, 220, 90},
        port: 4124,
        population: 0,
        capacity: 1_000_000
      }
    ]
  end
end
