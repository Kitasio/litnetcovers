defmodule LitcoversWeb.PlaceholderControllerTest do
  use LitcoversWeb.ConnCase

  import Litcovers.MediaFixtures

  @create_attrs %{author: "some author", description: "some description", title: "some title", vibe: "some vibe"}
  @update_attrs %{author: "some updated author", description: "some updated description", title: "some updated title", vibe: "some updated vibe"}
  @invalid_attrs %{author: nil, description: nil, title: nil, vibe: nil}

  describe "index" do
    test "lists all placeholders", %{conn: conn} do
      conn = get(conn, Routes.placeholder_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Placeholders"
    end
  end

  describe "new placeholder" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.placeholder_path(conn, :new))
      assert html_response(conn, 200) =~ "New Placeholder"
    end
  end

  describe "create placeholder" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.placeholder_path(conn, :create), placeholder: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.placeholder_path(conn, :show, id)

      conn = get(conn, Routes.placeholder_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Placeholder"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.placeholder_path(conn, :create), placeholder: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Placeholder"
    end
  end

  describe "edit placeholder" do
    setup [:create_placeholder]

    test "renders form for editing chosen placeholder", %{conn: conn, placeholder: placeholder} do
      conn = get(conn, Routes.placeholder_path(conn, :edit, placeholder))
      assert html_response(conn, 200) =~ "Edit Placeholder"
    end
  end

  describe "update placeholder" do
    setup [:create_placeholder]

    test "redirects when data is valid", %{conn: conn, placeholder: placeholder} do
      conn = put(conn, Routes.placeholder_path(conn, :update, placeholder), placeholder: @update_attrs)
      assert redirected_to(conn) == Routes.placeholder_path(conn, :show, placeholder)

      conn = get(conn, Routes.placeholder_path(conn, :show, placeholder))
      assert html_response(conn, 200) =~ "some updated author"
    end

    test "renders errors when data is invalid", %{conn: conn, placeholder: placeholder} do
      conn = put(conn, Routes.placeholder_path(conn, :update, placeholder), placeholder: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Placeholder"
    end
  end

  describe "delete placeholder" do
    setup [:create_placeholder]

    test "deletes chosen placeholder", %{conn: conn, placeholder: placeholder} do
      conn = delete(conn, Routes.placeholder_path(conn, :delete, placeholder))
      assert redirected_to(conn) == Routes.placeholder_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.placeholder_path(conn, :show, placeholder))
      end
    end
  end

  defp create_placeholder(_) do
    placeholder = placeholder_fixture()
    %{placeholder: placeholder}
  end
end
