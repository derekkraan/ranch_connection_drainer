defmodule RanchConnectionDrainerTest do
  use ExUnit.Case, async: false
  doctest RanchConnectionDrainer
  use Mockery
  import ExUnit.CaptureLog

  setup do
    ref = RanchConnectionDrainer.Endpoint.HTTP

    children = [
      Server.new(ref),
      {RanchConnectionDrainer, ranch_ref: ref}
    ]

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    assert :ranch.info()
           |> Enum.any?(fn conn -> match?({^ref, _}, conn) end)

    assert ref
           |> :ranch.info()
           |> Keyword.get(:status) == :running

    on_exit(fn ->
      # Wait for Supervisor to shut down. Calling if Process.alive?(pid), do: Supervisor.stop(pid)
      # ran into a race condition. Process.alive?(pid) would return true, but it would be dead by the time
      # Supervisor.stop(pid) was executed.
      :timer.sleep(10)
    end)

    [supervisor: pid, ref: ref]
  end

  describe "RanchConnectionDrainer" do
    test "basic setup", %{supervisor: pid, ref: ref} do
      logs =
        capture_log(fn ->
          Supervisor.stop(pid)
        end)

      ref_string =
        ref
        |> Module.split()
        |> Enum.join(".")

      assert String.match?(logs, ~r/Suspending listener #{ref_string}/)
      assert String.match?(logs, ~r/Connections successfully drained for listener #{ref_string}/)
    end
  end

  describe "RanchConnectionDrainer.terminate/2" do
    test "calls ranch to suspend and wait for no more connections, and calls delegate callbacks",
         %{ref: ref} do
      RanchConnectionDrainer.terminate(:shutdown,
        ranch_ref: ref,
        delegate: RanchConnectionDrainer
      )

      assert_called(:ranch, :suspend_listener, [^ref])
      assert_called(:ranch, :wait_for_connections, [^ref, :==, 0])

      assert_called(RanchConnectionDrainer, :before_suspend, [:shutdown, ^ref])
      assert_called(RanchConnectionDrainer, :after_suspend, [:shutdown, ^ref])
      assert_called(RanchConnectionDrainer, :before_terminate, [:shutdown, ^ref, nil])
    end

    test "can be halted by the delegate return types", %{ref: ref} do
      mock(RanchConnectionDrainer, [before_suspend: 2], {:error, :abort})

      RanchConnectionDrainer.terminate(:shutdown,
        ranch_ref: ref,
        delegate: RanchConnectionDrainer
      )

      assert_called(RanchConnectionDrainer, :before_suspend, [:shutdown, ^ref])

      refute_called(:ranch, :suspend_listener)
      refute_called(:ranch, :wait_for_connections)

      refute_called(RanchConnectionDrainer, :after_suspend)
      assert_called(RanchConnectionDrainer, :before_terminate, [:shutdown, ^ref, :before_suspend])
    end
  end
end
