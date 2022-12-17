defmodule LitcoversWeb.PageController do
  use LitcoversWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def docs(conn, _params) do
    render(conn, "docs.html")
  end

  def dummy(_conn, _params), do: nil
end
