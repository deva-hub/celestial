defmodule CelestialPortal.Presence do
  @moduledoc false
  use Nostalex.Presence,
    otp_app: :celestial_portal,
    pubsub_server: Celestial.PubSub
end
