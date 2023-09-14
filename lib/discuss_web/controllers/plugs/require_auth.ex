defmodule DiscussWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller
  import Phoenix.VerifiedRoutes


  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be signed in")
      |> redirect(to: path(conn, DiscussWeb.Router, ~p"/topics"))
      |> halt()
    end
  end
end
