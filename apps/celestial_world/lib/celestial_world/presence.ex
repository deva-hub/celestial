defmodule CelestialWorld.Presence do
  @moduledoc false
  use Nostalex.Presence,
    otp_app: :celestial_world,
    pubsub_server: Celestial.PubSub
end
