# RanchConnectionDrainer [![Hex pm](http://img.shields.io/hexpm/v/ranch_connection_drainer.svg?style=flat)](https://hex.pm/packages/ranch_connection_drainer)

This mini library implements connection draining for servers that use Ranch (Cowboy, Plug, Phoenix, and maybe others).

## Installation

This package can be installed by adding `ranch_connection_drainer` to your list of dependencies in `mix.exs`:

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
