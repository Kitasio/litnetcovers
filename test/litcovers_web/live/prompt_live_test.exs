defmodule LitcoversWeb.PromptLiveTest do
  use LitcoversWeb.ConnCase

  import Phoenix.LiveViewTest
  import Litcovers.SdFixtures

  @create_attrs %{final_prompt: "some final_prompt", name: "some name", realm: :fantasy, sentiment: :positive, style_prompt: "some style_prompt", type: :object}
  @update_attrs %{final_prompt: "some updated final_prompt", name: "some updated name", realm: :realism, sentiment: :neutral, style_prompt: "some updated style_prompt", type: :subject}
  @invalid_attrs %{final_prompt: nil, name: nil, realm: nil, sentiment: nil, style_prompt: nil, type: nil}

  defp create_prompt(_) do
    prompt = prompt_fixture()
    %{prompt: prompt}
  end

  describe "Index" do
    setup [:create_prompt]

    test "lists all prompts", %{conn: conn, prompt: prompt} do
      {:ok, _index_live, html} = live(conn, Routes.prompt_index_path(conn, :index))

      assert html =~ "Listing Prompts"
      assert html =~ prompt.final_prompt
    end

    test "saves new prompt", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.prompt_index_path(conn, :index))

      assert index_live |> element("a", "New Prompt") |> render_click() =~
               "New Prompt"

      assert_patch(index_live, Routes.prompt_index_path(conn, :new))

      assert index_live
             |> form("#prompt-form", prompt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#prompt-form", prompt: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.prompt_index_path(conn, :index))

      assert html =~ "Prompt created successfully"
      assert html =~ "some final_prompt"
    end

    test "updates prompt in listing", %{conn: conn, prompt: prompt} do
      {:ok, index_live, _html} = live(conn, Routes.prompt_index_path(conn, :index))

      assert index_live |> element("#prompt-#{prompt.id} a", "Edit") |> render_click() =~
               "Edit Prompt"

      assert_patch(index_live, Routes.prompt_index_path(conn, :edit, prompt))

      assert index_live
             |> form("#prompt-form", prompt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#prompt-form", prompt: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.prompt_index_path(conn, :index))

      assert html =~ "Prompt updated successfully"
      assert html =~ "some updated final_prompt"
    end

    test "deletes prompt in listing", %{conn: conn, prompt: prompt} do
      {:ok, index_live, _html} = live(conn, Routes.prompt_index_path(conn, :index))

      assert index_live |> element("#prompt-#{prompt.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#prompt-#{prompt.id}")
    end
  end

  describe "Show" do
    setup [:create_prompt]

    test "displays prompt", %{conn: conn, prompt: prompt} do
      {:ok, _show_live, html} = live(conn, Routes.prompt_show_path(conn, :show, prompt))

      assert html =~ "Show Prompt"
      assert html =~ prompt.final_prompt
    end

    test "updates prompt within modal", %{conn: conn, prompt: prompt} do
      {:ok, show_live, _html} = live(conn, Routes.prompt_show_path(conn, :show, prompt))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Prompt"

      assert_patch(show_live, Routes.prompt_show_path(conn, :edit, prompt))

      assert show_live
             |> form("#prompt-form", prompt: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#prompt-form", prompt: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.prompt_show_path(conn, :show, prompt))

      assert html =~ "Prompt updated successfully"
      assert html =~ "some updated final_prompt"
    end
  end
end
