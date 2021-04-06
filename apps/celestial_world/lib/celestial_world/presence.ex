defmodule CelestialWorld.Presence do
  @moduledoc false
  use CelestialNetwork.Presence,
    otp_app: :celestial_world,
    pubsub_server: Celestial.PubSub
end
