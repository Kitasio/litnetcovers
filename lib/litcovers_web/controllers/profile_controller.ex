defmodule LitcoversWeb.ProfileController do
  use LitcoversWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
