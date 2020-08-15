defmodule RanchConnectionDrainer.Delegate do
  @moduledoc """
  Delegate for callback functions during the terminate process.

  If a host wants to execute some side effect after connections are suspended, but
  before connections are drained (i.e. start returning 500s to kubernete's readiness probe, to stop traffic)
  then they can use this module

  Example
  ```
  defmodule ShutdownHandler do
    @moduledoc false

    use RanchConnectionDrainer.Delegate

    @impl
    def after_suspend(_, _) do
      # ... tell application's readiness probe endpoint to start sending 500s
      {:ok, :continue}
    end
  end

  # pass in your delegate module as a configuration option to the RanchConnectionDrainer

  children = [
      MyPhoenixProject.Endpoint,,
      {RanchConnectionDrainer, ranch_ref: MyPhoenixProject.Endpoint.HTTP, delegate: ShutdownHandler}
    ]

  Supervisor.init(children, strategy: :one_for_one)
  ```

  Each callback function that you override must return a tuple with an `:ok` atom as the first element for the
  normal draining process to be executed as expected. If your implementation returns anything else all subsequent
  steps will be disregarded. The `RanchConnectionDrainer.Delegate.before_terminate/3` callback will always be
  executed and the 3 parameter will be an atom representing the last step executed, or `nil` if all steps were
  executed.
  """

  @type reason() :: :normal | :shutdown | {:shutdown, term} | term
  @type step() :: nil | :before_suspend | :suspend | :after_suspend | :wait

  @callback before_suspend(reason(), module()) :: {:ok, atom()} | {:error, atom()}
  @callback after_suspend(reason(), module()) :: {:ok, atom()} | {:error, atom()}
  @callback before_terminate(reason(), module(), step()) :: {:ok, atom()} | {:error, atom()}

  defmacro __using__(_params) do
    quote do
      @behaviour RanchConnectionDrainer.Delegate

      # Define implementation for user modules to use
      def before_suspend(_reason, _module), do: {:ok, :continue}
      def after_suspend(_reason, _module), do: {:ok, :continue}
      def before_terminate(_reason, _module, _step), do: {:ok, :continue}

      # Defoverridable makes the given functions in the current module overridable
      # Without defoverridable, new definitions of greet will not be picked up
      defoverridable before_suspend: 2, after_suspend: 2, before_terminate: 3
    end
  end
end
