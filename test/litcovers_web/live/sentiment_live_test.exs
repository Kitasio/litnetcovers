defmodule LitcoversWeb.SentimentLiveTest do
  use LitcoversWeb.ConnCase

  import Phoenix.LiveViewTest
  import Litcovers.SdFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  defp create_sentiment(_) do
    sentiment = sentiment_fixture()
    %{sentiment: sentiment}
  end

  describe "Index" do
    setup [:create_sentiment]

    test "lists all sentiments", %{conn: conn, sentiment: sentiment} do
      {:ok, _index_live, html} = live(conn, Routes.sentiment_index_path(conn, :index))

      assert html =~ "Listing Sentiments"
      assert html =~ sentiment.title
    end

    test "saves new sentiment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.sentiment_index_path(conn, :index))

      assert index_live |> element("a", "New Sentiment") |> render_click() =~
               "New Sentiment"

      assert_patch(index_live, Routes.sentiment_index_path(conn, :new))

      assert index_live
             |> form("#sentiment-form", sentiment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#sentiment-form", sentiment: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.sentiment_index_path(conn, :index))

      assert html =~ "Sentiment created successfully"
      assert html =~ "some title"
    end

    test "updates sentiment in listing", %{conn: conn, sentiment: sentiment} do
      {:ok, index_live, _html} = live(conn, Routes.sentiment_index_path(conn, :index))

      assert index_live |> element("#sentiment-#{sentiment.id} a", "Edit") |> render_click() =~
               "Edit Sentiment"

      assert_patch(index_live, Routes.sentiment_index_path(conn, :edit, sentiment))

      assert index_live
             |> form("#sentiment-form", sentiment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#sentiment-form", sentiment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.sentiment_index_path(conn, :index))

      assert html =~ "Sentiment updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes sentiment in listing", %{conn: conn, sentiment: sentiment} do
      {:ok, index_live, _html} = live(conn, Routes.sentiment_index_path(conn, :index))

      assert index_live |> element("#sentiment-#{sentiment.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#sentiment-#{sentiment.id}")
    end
  end

  describe "Show" do
    setup [:create_sentiment]

    test "displays sentiment", %{conn: conn, sentiment: sentiment} do
      {:ok, _show_live, html} = live(conn, Routes.sentiment_show_path(conn, :show, sentiment))

      assert html =~ "Show Sentiment"
      assert html =~ sentiment.title
    end

    test "updates sentiment within modal", %{conn: conn, sentiment: sentiment} do
      {:ok, show_live, _html} = live(conn, Routes.sentiment_show_path(conn, :show, sentiment))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Sentiment"

      assert_patch(show_live, Routes.sentiment_show_path(conn, :edit, sentiment))

      assert show_live
             |> form("#sentiment-form", sentiment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#sentiment-form", sentiment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.sentiment_show_path(conn, :show, sentiment))

      assert html =~ "Sentiment updated successfully"
      assert html =~ "some updated title"
    end
  end
end
