defmodule LitcoversWeb.HairLiveTest do
  use LitcoversWeb.ConnCase

  import Phoenix.LiveViewTest
  import Litcovers.CharacterFixtures

  @create_attrs %{name: "some name", prompt: "some prompt"}
  @update_attrs %{name: "some updated name", prompt: "some updated prompt"}
  @invalid_attrs %{name: nil, prompt: nil}

  defp create_hair(_) do
    hair = hair_fixture()
    %{hair: hair}
  end

  describe "Index" do
    setup [:create_hair]

    test "lists all hair", %{conn: conn, hair: hair} do
      {:ok, _index_live, html} = live(conn, Routes.hair_index_path(conn, :index))

      assert html =~ "Listing Hair"
      assert html =~ hair.name
    end

    test "saves new hair", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.hair_index_path(conn, :index))

      assert index_live |> element("a", "New Hair") |> render_click() =~
               "New Hair"

      assert_patch(index_live, Routes.hair_index_path(conn, :new))

      assert index_live
             |> form("#hair-form", hair: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#hair-form", hair: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.hair_index_path(conn, :index))

      assert html =~ "Hair created successfully"
      assert html =~ "some name"
    end

    test "updates hair in listing", %{conn: conn, hair: hair} do
      {:ok, index_live, _html} = live(conn, Routes.hair_index_path(conn, :index))

      assert index_live |> element("#hair-#{hair.id} a", "Edit") |> render_click() =~
               "Edit Hair"

      assert_patch(index_live, Routes.hair_index_path(conn, :edit, hair))

      assert index_live
             |> form("#hair-form", hair: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#hair-form", hair: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.hair_index_path(conn, :index))

      assert html =~ "Hair updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes hair in listing", %{conn: conn, hair: hair} do
      {:ok, index_live, _html} = live(conn, Routes.hair_index_path(conn, :index))

      assert index_live |> element("#hair-#{hair.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#hair-#{hair.id}")
    end
  end

  describe "Show" do
    setup [:create_hair]

    test "displays hair", %{conn: conn, hair: hair} do
      {:ok, _show_live, html} = live(conn, Routes.hair_show_path(conn, :show, hair))

      assert html =~ "Show Hair"
      assert html =~ hair.name
    end

    test "updates hair within modal", %{conn: conn, hair: hair} do
      {:ok, show_live, _html} = live(conn, Routes.hair_show_path(conn, :show, hair))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Hair"

      assert_patch(show_live, Routes.hair_show_path(conn, :edit, hair))

      assert show_live
             |> form("#hair-form", hair: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#hair-form", hair: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.hair_show_path(conn, :show, hair))

      assert html =~ "Hair updated successfully"
      assert html =~ "some updated name"
    end
  end
end
