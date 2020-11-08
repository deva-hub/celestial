defmodule CelestialGateway.Server do
  def child_spec(options) do
    {ranch_options, proto_options} = Keyword.pop(options, :options, [])
    protocol = Keyword.fetch!(proto_options, :protocol)
    transport = Keyword.get(proto_options, :transport, :ranch_tcp)
    ref = build_ref(transport, protocol)
    :ranch.child_spec(ref, transport, ranch_options, protocol, [])
  end

  def build_ref(:ranch_tcp, protocol), do: Module.concat(protocol, :tcp)
  def build_ref(:ranch_ssl, protocol), do: Module.concat(protocol, :ssl)
end
