defmodule Controller do
  @moduledoc """
  Simple Controller to be used with tests
  """

  use Plug.Router
  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_header("Content-Type", "application/json")
    |> send_resp(200, "OK")
  end
end
