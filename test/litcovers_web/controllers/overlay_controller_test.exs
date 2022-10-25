defmodule LitcoversWeb.OverlayControllerTest do
  use LitcoversWeb.ConnCase

  import Litcovers.MediaFixtures

  alias Litcovers.Media.Overlay

  @create_attrs %{
    url: "some url"
  }
  @update_attrs %{
    url: "some updated url"
  }
  @invalid_attrs %{url: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all overlays", %{conn: conn} do
      conn = get(conn, Routes.overlay_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create overlay" do
    test "renders overlay when data is valid", %{conn: conn} do
      conn = post(conn, Routes.overlay_path(conn, :create), overlay: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.overlay_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "url" => "some url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.overlay_path(conn, :create), overlay: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update overlay" do
    setup [:create_overlay]

    test "renders overlay when data is valid", %{conn: conn, overlay: %Overlay{id: id} = overlay} do
      conn = put(conn, Routes.overlay_path(conn, :update, overlay), overlay: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.overlay_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "url" => "some updated url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, overlay: overlay} do
      conn = put(conn, Routes.overlay_path(conn, :update, overlay), overlay: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete overlay" do
    setup [:create_overlay]

    test "deletes chosen overlay", %{conn: conn, overlay: overlay} do
      conn = delete(conn, Routes.overlay_path(conn, :delete, overlay))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.overlay_path(conn, :show, overlay))
      end
    end
  end

  defp create_overlay(_) do
    overlay = overlay_fixture()
    %{overlay: overlay}
  end
end
