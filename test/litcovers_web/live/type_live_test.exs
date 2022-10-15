defmodule LitcoversWeb.TypeLiveTest do
  use LitcoversWeb.ConnCase

  import Phoenix.LiveViewTest
  import Litcovers.SdFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  defp create_type(_) do
    type = type_fixture()
    %{type: type}
  end

  describe "Index" do
    setup [:create_type]

    test "lists all types", %{conn: conn, type: type} do
      {:ok, _index_live, html} = live(conn, Routes.type_index_path(conn, :index))

      assert html =~ "Listing Types"
      assert html =~ type.title
    end

    test "saves new type", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.type_index_path(conn, :index))

      assert index_live |> element("a", "New Type") |> render_click() =~
               "New Type"

      assert_patch(index_live, Routes.type_index_path(conn, :new))

      assert index_live
             |> form("#type-form", type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#type-form", type: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.type_index_path(conn, :index))

      assert html =~ "Type created successfully"
      assert html =~ "some title"
    end

    test "updates type in listing", %{conn: conn, type: type} do
      {:ok, index_live, _html} = live(conn, Routes.type_index_path(conn, :index))

      assert index_live |> element("#type-#{type.id} a", "Edit") |> render_click() =~
               "Edit Type"

      assert_patch(index_live, Routes.type_index_path(conn, :edit, type))

      assert index_live
             |> form("#type-form", type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#type-form", type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.type_index_path(conn, :index))

      assert html =~ "Type updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes type in listing", %{conn: conn, type: type} do
      {:ok, index_live, _html} = live(conn, Routes.type_index_path(conn, :index))

      assert index_live |> element("#type-#{type.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#type-#{type.id}")
    end
  end

  describe "Show" do
    setup [:create_type]

    test "displays type", %{conn: conn, type: type} do
      {:ok, _show_live, html} = live(conn, Routes.type_show_path(conn, :show, type))

      assert html =~ "Show Type"
      assert html =~ type.title
    end

    test "updates type within modal", %{conn: conn, type: type} do
      {:ok, show_live, _html} = live(conn, Routes.type_show_path(conn, :show, type))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Type"

      assert_patch(show_live, Routes.type_show_path(conn, :edit, type))

      assert show_live
             |> form("#type-form", type: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#type-form", type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.type_show_path(conn, :show, type))

      assert html =~ "Type updated successfully"
      assert html =~ "some updated title"
    end
  end
end
