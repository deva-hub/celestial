defmodule CelestialWorld.Oracle do
  @moduledoc false

  def list_channels do
    [
      %{
        id: 1,
        world_id: 2,
        slot: 100,
        ip: {172, 21, 41, 36},
        port: 4124,
        population: 0,
        capacity: 1_000_000
      }
    ]
  end
end
