defmodule RanchConnectionDrainer do
  @moduledoc """
  Drain connections before shutting down.

  If your Phoenix endpoint is `MyPhoenix.Endpoint`, and you are running your server on http, then the correct value is `MyPhoenix.Endpoint.HTTP`. If you are running https, then you would use `MyPhoenix.Endpoint.HTTPS`.

  To add this to your application, simply add `{RanchConnectionDrainer, [ranch_ref: MyPhoenix.Endpoint.HTTP, shutdown: 10_000]}` to the line *below* `MyPhoenix.Endpoint` in your Application file.

  Example:

  ```
  children = [
    MyPhoenixProject.Endpoint,
    {RanchConnectionDrainer, ranch_ref: MyPhoenixProject.Endpoint.HTTP, shutdown: 30_000}
  ]
  Supervisor.init(children, opts)
  ```
  """

  use GenServer

  @spec child_spec(options :: keyword()) :: Supervisor.child_spec()
  def child_spec(options) when is_list(options) do
    ranch_ref = Keyword.fetch!(options, :ranch_ref)
    shutdown = Keyword.fetch!(options, :shutdown)

    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [ranch_ref, shutdown]},
      shutdown: shutdown
    }
  end

  @doc false
  def start_link(ranch_ref, shutdown) do
    GenServer.start_link(__MODULE__, {ranch_ref, shutdown})
  end

  @doc false
  def init({ranch_ref, shutdown}) do
    Process.flag(:trap_exit, true)
    {:ok, {ranch_ref, shutdown}}
  end

  def terminate(_reason, {ranch_ref, shutdown}) do
    :ok = :ranch.suspend_listener(ranch_ref)
    :ok = :ranch.wait_for_connections(ranch_ref, :==, 0, shutdown)
  end
end
