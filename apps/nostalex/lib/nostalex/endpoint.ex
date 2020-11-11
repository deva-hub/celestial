defmodule Nostalex.Endpoint do
  @moduledoc false
  require Logger
  alias Nostalex.Endpoint.Protocol

  def child_spec(opts \\ []) do
    scheme = Keyword.get(opts, :scheme, :tcp)
    port = Keyword.fetch!(opts, :port)
    handler = Keyword.fetch!(opts, :handler)
    trans_opts = transport_config(port, opts)
    proto_opts = protocol_config(handler, opts)
    ref = build_ref(scheme, handler)

    ranch_module =
      case scheme do
        :tcp -> :ranch_tcp
        :ssl -> :ranch_ssl
      end

    :ranch.child_spec(ref, ranch_module, trans_opts, Protocol, proto_opts)
  end

  defp transport_config(port, opts) do
    opts
    |> Keyword.get(:transport_opts, [])
    |> Keyword.put(:port, port)
    |> :ranch.normalize_opts()
  end

  defp protocol_config(handler, opts) do
    opts
    |> Keyword.get(:protocol_opts, [])
    |> Keyword.put(:handler, handler)
  end

  defp build_ref(plug, scheme) do
    Module.concat(plug, scheme |> to_string |> String.upcase())
  end
end
