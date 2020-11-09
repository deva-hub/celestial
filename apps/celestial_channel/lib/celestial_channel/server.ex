defmodule CelestialChannel.Server do
  @moduledoc false

  @default_transport :ranch_tcp
  @default_protocol CelestialChannel.Protocol
  @default_port 4124

  def child_spec(opts \\ []) do
    {transport, transport_opts} = transport_config(opts)
    {protocol, protocole_opts} = protocol_config(opts)
    ref = build_ref(transport, protocol)
    :ranch.child_spec(ref, transport, transport_opts, protocol, protocole_opts)
  end

  defp transport_config(opts) do
    port = Keyword.get(opts, :port, @default_port)
    mod = Keyword.get(opts, :transport, @default_transport)

    opts =
      opts
      |> Keyword.get(:transport_opts, [])
      |> Keyword.put(:port, port)
      |> :ranch.normalize_opts()

    {mod, opts}
  end

  defp protocol_config(opts) do
    mod = Keyword.get(opts, :protocol, @default_protocol)
    opts = Keyword.get(opts, :protocol_opts, [])
    {mod, opts}
  end

  defp build_ref(:ranch_tcp, protocol), do: Module.concat(protocol, "TCP")
  defp build_ref(:ranch_ssl, protocol), do: Module.concat(protocol, "SSL")
end
