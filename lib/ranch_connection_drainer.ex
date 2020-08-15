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
  use RanchConnectionDrainer.Delegate
  require Logger
  import Mockery.Macro

  @spec child_spec(options :: keyword()) :: Supervisor.child_spec()
  def child_spec(options) when is_list(options) do
    id = Keyword.get(options, :id, __MODULE__)
    ranch_ref = Keyword.fetch!(options, :ranch_ref)
    shutdown = Keyword.get(options, :shutdown, 30_000)
    delegate = Keyword.get(options, :delegate, RanchConnectionDrainer)

    %{
      id: id,
      start: {__MODULE__, :start_link, [[ranch_ref: ranch_ref, delegate: delegate]]},
      shutdown: shutdown
    }
  end

  @doc false
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @doc false
  def init(args) do
    Process.flag(:trap_exit, true)
    {:ok, args}
  end

  defp ranch, do: mockable(:ranch)

  def terminate(reason, ranch_ref: ranch_ref, delegate: delegate) do
    Logger.info("Suspending listener #{inspect(ranch_ref)}")

    with {:before_suspend, {:ok, :continue}} <-
           {:before_suspend, mockable(delegate).before_suspend(reason, ranch_ref)},
         {:suspend, :ok} <- {:suspend, ranch().suspend_listener(ranch_ref)},
         {:after_suspend, {:ok, :continue}} <-
           {:after_suspend, mockable(delegate).after_suspend(reason, ranch_ref)},
         {:wait, :ok} <- {:wait, ranch().wait_for_connections(ranch_ref, :==, 0)} do
      Logger.info("Connections successfully drained for listener #{inspect(ranch_ref)}")
      mockable(delegate).before_terminate(reason, ranch_ref, nil)
    else
      {step, _} ->
        Logger.info("Connections successfully drained for listener #{inspect(ranch_ref)}")
        mockable(delegate).before_terminate(reason, ranch_ref, step)
    end
  end
end
