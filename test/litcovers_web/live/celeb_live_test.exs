defmodule LitcoversWeb.CelebLiveTest do
  use LitcoversWeb.ConnCase

  import Phoenix.LiveViewTest
  import Litcovers.CharacterFixtures

  @create_attrs %{famous: true, gender: :male, name: "some name"}
  @update_attrs %{famous: false, gender: :female, name: "some updated name"}
  @invalid_attrs %{famous: false, gender: nil, name: nil}

  defp create_celeb(_) do
    celeb = celeb_fixture()
    %{celeb: celeb}
  end

  describe "Index" do
    setup [:create_celeb]

    test "lists all celebs", %{conn: conn, celeb: celeb} do
      {:ok, _index_live, html} = live(conn, Routes.celeb_index_path(conn, :index))

      assert html =~ "Listing Celebs"
      assert html =~ celeb.name
    end

    test "saves new celeb", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.celeb_index_path(conn, :index))

      assert index_live |> element("a", "New Celeb") |> render_click() =~
               "New Celeb"

      assert_patch(index_live, Routes.celeb_index_path(conn, :new))

      assert index_live
             |> form("#celeb-form", celeb: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#celeb-form", celeb: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.celeb_index_path(conn, :index))

      assert html =~ "Celeb created successfully"
      assert html =~ "some name"
    end

    test "updates celeb in listing", %{conn: conn, celeb: celeb} do
      {:ok, index_live, _html} = live(conn, Routes.celeb_index_path(conn, :index))

      assert index_live |> element("#celeb-#{celeb.id} a", "Edit") |> render_click() =~
               "Edit Celeb"

      assert_patch(index_live, Routes.celeb_index_path(conn, :edit, celeb))

      assert index_live
             |> form("#celeb-form", celeb: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#celeb-form", celeb: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.celeb_index_path(conn, :index))

      assert html =~ "Celeb updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes celeb in listing", %{conn: conn, celeb: celeb} do
      {:ok, index_live, _html} = live(conn, Routes.celeb_index_path(conn, :index))

      assert index_live |> element("#celeb-#{celeb.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#celeb-#{celeb.id}")
    end
  end

  describe "Show" do
    setup [:create_celeb]

    test "displays celeb", %{conn: conn, celeb: celeb} do
      {:ok, _show_live, html} = live(conn, Routes.celeb_show_path(conn, :show, celeb))

      assert html =~ "Show Celeb"
      assert html =~ celeb.name
    end

    test "updates celeb within modal", %{conn: conn, celeb: celeb} do
      {:ok, show_live, _html} = live(conn, Routes.celeb_show_path(conn, :show, celeb))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Celeb"

      assert_patch(show_live, Routes.celeb_show_path(conn, :edit, celeb))

      assert show_live
             |> form("#celeb-form", celeb: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#celeb-form", celeb: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.celeb_show_path(conn, :show, celeb))

      assert html =~ "Celeb updated successfully"
      assert html =~ "some updated name"
    end
  end
end
