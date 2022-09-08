defmodule LitcoversWeb.ProfileController do
  use LitcoversWeb, :controller

  alias Litcovers.Media

  def index(conn, _params) do
    requests = Media.list_user_requests(conn.assigns.current_user)
    render(conn, "index.html", requests: requests)
  end
end
