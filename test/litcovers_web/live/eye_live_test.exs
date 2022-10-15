defmodule LitcoversWeb.EyeLiveTest do
  use LitcoversWeb.ConnCase

  import Phoenix.LiveViewTest
  import Litcovers.CharacterFixtures

  @create_attrs %{color: "some color", prompt: "some prompt"}
  @update_attrs %{color: "some updated color", prompt: "some updated prompt"}
  @invalid_attrs %{color: nil, prompt: nil}

  defp create_eye(_) do
    eye = eye_fixture()
    %{eye: eye}
  end

  describe "Index" do
    setup [:create_eye]

    test "lists all eyes", %{conn: conn, eye: eye} do
      {:ok, _index_live, html} = live(conn, Routes.eye_index_path(conn, :index))

      assert html =~ "Listing Eyes"
      assert html =~ eye.color
    end

    test "saves new eye", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.eye_index_path(conn, :index))

      assert index_live |> element("a", "New Eye") |> render_click() =~
               "New Eye"

      assert_patch(index_live, Routes.eye_index_path(conn, :new))

      assert index_live
             |> form("#eye-form", eye: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#eye-form", eye: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.eye_index_path(conn, :index))

      assert html =~ "Eye created successfully"
      assert html =~ "some color"
    end

    test "updates eye in listing", %{conn: conn, eye: eye} do
      {:ok, index_live, _html} = live(conn, Routes.eye_index_path(conn, :index))

      assert index_live |> element("#eye-#{eye.id} a", "Edit") |> render_click() =~
               "Edit Eye"

      assert_patch(index_live, Routes.eye_index_path(conn, :edit, eye))

      assert index_live
             |> form("#eye-form", eye: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#eye-form", eye: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.eye_index_path(conn, :index))

      assert html =~ "Eye updated successfully"
      assert html =~ "some updated color"
    end

    test "deletes eye in listing", %{conn: conn, eye: eye} do
      {:ok, index_live, _html} = live(conn, Routes.eye_index_path(conn, :index))

      assert index_live |> element("#eye-#{eye.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#eye-#{eye.id}")
    end
  end

  describe "Show" do
    setup [:create_eye]

    test "displays eye", %{conn: conn, eye: eye} do
      {:ok, _show_live, html} = live(conn, Routes.eye_show_path(conn, :show, eye))

      assert html =~ "Show Eye"
      assert html =~ eye.color
    end

    test "updates eye within modal", %{conn: conn, eye: eye} do
      {:ok, show_live, _html} = live(conn, Routes.eye_show_path(conn, :show, eye))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Eye"

      assert_patch(show_live, Routes.eye_show_path(conn, :edit, eye))

      assert show_live
             |> form("#eye-form", eye: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#eye-form", eye: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.eye_show_path(conn, :show, eye))

      assert html =~ "Eye updated successfully"
      assert html =~ "some updated color"
    end
  end
end
