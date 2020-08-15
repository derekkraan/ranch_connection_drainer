defmodule Server do
  @moduledoc """
  :ranch server factory
  """

  def new(ref, options \\ []) do
    {ref, transport, trans_opts, protocol, proto_opts} =
      {ref, :ranch_tcp,
       %{
         max_connections: 16_384,
         num_acceptors: 100,
         socket_opts: [port: Keyword.get(options, :port, 4000)]
       }, :cowboy_clear, protocol_options(Keyword.get(options, :endpoint, Controller))}

    :ranch.child_spec(ref, transport, trans_opts, protocol, proto_opts)
  end

  defp protocol_options(endpoint_name) do
    %{
      env: %{
        dispatch: [
          {:_, [], [{:_, [], Plug.Cowboy.Handler, {endpoint_name, {:ok, []}}}]}
        ]
      },
      stream_handlers: [Plug.Cowboy.Stream]
    }
  end
end
