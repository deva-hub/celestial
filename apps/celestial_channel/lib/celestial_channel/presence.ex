defmodule CelestialChannel.Presence do
  @moduledoc false
  use Nostalex.Presence,
    otp_app: :celestial_channel,
    pubsub_server: Celestial.PubSub
end
