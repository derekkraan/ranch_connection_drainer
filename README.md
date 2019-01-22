# RanchConnectionDrainer

This mini library implements connection draining for servers that use Ranch (Cowboy, Plug, Phoenix, and maybe others).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ranch_connection_drainer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ranch_connection_drainer, "~> 0.1.0"}
  ]
end
```

Then add `{RanchConnectionDrainer, ranch_ref: my_ranch_ref, shutdown: my_drain_timeout}` to your application supervisor directly under your phoenix endpoint.

Example:

```elixir
children = [
  MyPhoenixProject.Endpoint,
  {RanchConnectionDrainer, ranch_ref: MyPhoenixProject.Endpoint.HTTP, shutdown: 30_000}
]
Supervisor.init(children, opts)
```

The format of `ranch_ref` is: `[PhoenixEndpoint].[HTTP | HTTPS]`. Please open an issue if this is unclear.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ranch_connection_drainer](https://hexdocs.pm/ranch_connection_drainer).
