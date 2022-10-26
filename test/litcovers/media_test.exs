defmodule Litcovers.MediaTest do
  use Litcovers.DataCase

  alias Litcovers.Media

  describe "requests" do
    alias Litcovers.Media.Request

    import Litcovers.MediaFixtures

    @invalid_attrs %{author: nil, description: nil, genre: nil, max: nil, status: nil, title: nil, vibe: nil}

    test "list_requests/0 returns all requests" do
      request = request_fixture()
      assert Media.list_requests() == [request]
    end

    test "get_request!/1 returns the request with given id" do
      request = request_fixture()
      assert Media.get_request!(request.id) == request
    end

    test "create_request/1 with valid data creates a request" do
      valid_attrs = %{author: "some author", description: "some description", genre: "some genre", max: 42, status: "some status", title: "some title", vibe: "some vibe"}

      assert {:ok, %Request{} = request} = Media.create_request(valid_attrs)
      assert request.author == "some author"
      assert request.description == "some description"
      assert request.genre == "some genre"
      assert request.max == 42
      assert request.status == "some status"
      assert request.title == "some title"
      assert request.vibe == "some vibe"
    end

    test "create_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_request(@invalid_attrs)
    end

    test "update_request/2 with valid data updates the request" do
      request = request_fixture()
      update_attrs = %{author: "some updated author", description: "some updated description", genre: "some updated genre", max: 43, status: "some updated status", title: "some updated title", vibe: "some updated vibe"}

      assert {:ok, %Request{} = request} = Media.update_request(request, update_attrs)
      assert request.author == "some updated author"
      assert request.description == "some updated description"
      assert request.genre == "some updated genre"
      assert request.max == 43
      assert request.status == "some updated status"
      assert request.title == "some updated title"
      assert request.vibe == "some updated vibe"
    end

    test "update_request/2 with invalid data returns error changeset" do
      request = request_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_request(request, @invalid_attrs)
      assert request == Media.get_request!(request.id)
    end

    test "delete_request/1 deletes the request" do
      request = request_fixture()
      assert {:ok, %Request{}} = Media.delete_request(request)
      assert_raise Ecto.NoResultsError, fn -> Media.get_request!(request.id) end
    end

    test "change_request/1 returns a request changeset" do
      request = request_fixture()
      assert %Ecto.Changeset{} = Media.change_request(request)
    end
  end

  describe "placeholders" do
    alias Litcovers.Media.Placeholder

    import Litcovers.MediaFixtures

    @invalid_attrs %{author: nil, description: nil, title: nil, vibe: nil}

    test "list_placeholders/0 returns all placeholders" do
      placeholder = placeholder_fixture()
      assert Media.list_placeholders() == [placeholder]
    end

    test "get_placeholder!/1 returns the placeholder with given id" do
      placeholder = placeholder_fixture()
      assert Media.get_placeholder!(placeholder.id) == placeholder
    end

    test "create_placeholder/1 with valid data creates a placeholder" do
      valid_attrs = %{author: "some author", description: "some description", title: "some title", vibe: "some vibe"}

      assert {:ok, %Placeholder{} = placeholder} = Media.create_placeholder(valid_attrs)
      assert placeholder.author == "some author"
      assert placeholder.description == "some description"
      assert placeholder.title == "some title"
      assert placeholder.vibe == "some vibe"
    end

    test "create_placeholder/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_placeholder(@invalid_attrs)
    end

    test "update_placeholder/2 with valid data updates the placeholder" do
      placeholder = placeholder_fixture()
      update_attrs = %{author: "some updated author", description: "some updated description", title: "some updated title", vibe: "some updated vibe"}

      assert {:ok, %Placeholder{} = placeholder} = Media.update_placeholder(placeholder, update_attrs)
      assert placeholder.author == "some updated author"
      assert placeholder.description == "some updated description"
      assert placeholder.title == "some updated title"
      assert placeholder.vibe == "some updated vibe"
    end

    test "update_placeholder/2 with invalid data returns error changeset" do
      placeholder = placeholder_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_placeholder(placeholder, @invalid_attrs)
      assert placeholder == Media.get_placeholder!(placeholder.id)
    end

    test "delete_placeholder/1 deletes the placeholder" do
      placeholder = placeholder_fixture()
      assert {:ok, %Placeholder{}} = Media.delete_placeholder(placeholder)
      assert_raise Ecto.NoResultsError, fn -> Media.get_placeholder!(placeholder.id) end
    end

    test "change_placeholder/1 returns a placeholder changeset" do
      placeholder = placeholder_fixture()
      assert %Ecto.Changeset{} = Media.change_placeholder(placeholder)
    end
  end

  describe "covers" do
    alias Litcovers.Media.Cover

    import Litcovers.MediaFixtures

    @invalid_attrs %{cover_url: nil}

    test "list_covers/0 returns all covers" do
      cover = cover_fixture()
      assert Media.list_covers() == [cover]
    end

    test "get_cover!/1 returns the cover with given id" do
      cover = cover_fixture()
      assert Media.get_cover!(cover.id) == cover
    end

    test "create_cover/1 with valid data creates a cover" do
      valid_attrs = %{cover_url: "some cover_url"}

      assert {:ok, %Cover{} = cover} = Media.create_cover(valid_attrs)
      assert cover.cover_url == "some cover_url"
    end

    test "create_cover/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_cover(@invalid_attrs)
    end

    test "update_cover/2 with valid data updates the cover" do
      cover = cover_fixture()
      update_attrs = %{cover_url: "some updated cover_url"}

      assert {:ok, %Cover{} = cover} = Media.update_cover(cover, update_attrs)
      assert cover.cover_url == "some updated cover_url"
    end

    test "update_cover/2 with invalid data returns error changeset" do
      cover = cover_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_cover(cover, @invalid_attrs)
      assert cover == Media.get_cover!(cover.id)
    end

    test "delete_cover/1 deletes the cover" do
      cover = cover_fixture()
      assert {:ok, %Cover{}} = Media.delete_cover(cover)
      assert_raise Ecto.NoResultsError, fn -> Media.get_cover!(cover.id) end
    end

    test "change_cover/1 returns a cover changeset" do
      cover = cover_fixture()
      assert %Ecto.Changeset{} = Media.change_cover(cover)
    end
  end

  describe "overlays" do
    alias Litcovers.Media.Overlay

    import Litcovers.MediaFixtures

    @invalid_attrs %{url: nil}

    test "list_overlays/0 returns all overlays" do
      overlay = overlay_fixture()
      assert Media.list_overlays() == [overlay]
    end

    test "get_overlay!/1 returns the overlay with given id" do
      overlay = overlay_fixture()
      assert Media.get_overlay!(overlay.id) == overlay
    end

    test "create_overlay/1 with valid data creates a overlay" do
      valid_attrs = %{url: "some url"}

      assert {:ok, %Overlay{} = overlay} = Media.create_overlay(valid_attrs)
      assert overlay.url == "some url"
    end

    test "create_overlay/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_overlay(@invalid_attrs)
    end

    test "update_overlay/2 with valid data updates the overlay" do
      overlay = overlay_fixture()
      update_attrs = %{url: "some updated url"}

      assert {:ok, %Overlay{} = overlay} = Media.update_overlay(overlay, update_attrs)
      assert overlay.url == "some updated url"
    end

    test "update_overlay/2 with invalid data returns error changeset" do
      overlay = overlay_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_overlay(overlay, @invalid_attrs)
      assert overlay == Media.get_overlay!(overlay.id)
    end

    test "delete_overlay/1 deletes the overlay" do
      overlay = overlay_fixture()
      assert {:ok, %Overlay{}} = Media.delete_overlay(overlay)
      assert_raise Ecto.NoResultsError, fn -> Media.get_overlay!(overlay.id) end
    end

    test "change_overlay/1 returns a overlay changeset" do
      overlay = overlay_fixture()
      assert %Ecto.Changeset{} = Media.change_overlay(overlay)
    end
  end

  describe "ideas" do
    alias Litcovers.Media.Idea

    import Litcovers.MediaFixtures

    @invalid_attrs %{idea: nil}

    test "list_ideas/0 returns all ideas" do
      idea = idea_fixture()
      assert Media.list_ideas() == [idea]
    end

    test "get_idea!/1 returns the idea with given id" do
      idea = idea_fixture()
      assert Media.get_idea!(idea.id) == idea
    end

    test "create_idea/1 with valid data creates a idea" do
      valid_attrs = %{idea: "some idea"}

      assert {:ok, %Idea{} = idea} = Media.create_idea(valid_attrs)
      assert idea.idea == "some idea"
    end

    test "create_idea/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_idea(@invalid_attrs)
    end

    test "update_idea/2 with valid data updates the idea" do
      idea = idea_fixture()
      update_attrs = %{idea: "some updated idea"}

      assert {:ok, %Idea{} = idea} = Media.update_idea(idea, update_attrs)
      assert idea.idea == "some updated idea"
    end

    test "update_idea/2 with invalid data returns error changeset" do
      idea = idea_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_idea(idea, @invalid_attrs)
      assert idea == Media.get_idea!(idea.id)
    end

    test "delete_idea/1 deletes the idea" do
      idea = idea_fixture()
      assert {:ok, %Idea{}} = Media.delete_idea(idea)
      assert_raise Ecto.NoResultsError, fn -> Media.get_idea!(idea.id) end
    end

    test "change_idea/1 returns a idea changeset" do
      idea = idea_fixture()
      assert %Ecto.Changeset{} = Media.change_idea(idea)
    end
  end

  describe "title_splits" do
    alias Litcovers.Media.TitleSplit

    import Litcovers.MediaFixtures

    @invalid_attrs %{split: nil}

    test "list_title_splits/0 returns all title_splits" do
      title_split = title_split_fixture()
      assert Media.list_title_splits() == [title_split]
    end

    test "get_title_split!/1 returns the title_split with given id" do
      title_split = title_split_fixture()
      assert Media.get_title_split!(title_split.id) == title_split
    end

    test "create_title_split/1 with valid data creates a title_split" do
      valid_attrs = %{split: "some split"}

      assert {:ok, %TitleSplit{} = title_split} = Media.create_title_split(valid_attrs)
      assert title_split.split == "some split"
    end

    test "create_title_split/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_title_split(@invalid_attrs)
    end

    test "update_title_split/2 with valid data updates the title_split" do
      title_split = title_split_fixture()
      update_attrs = %{split: "some updated split"}

      assert {:ok, %TitleSplit{} = title_split} = Media.update_title_split(title_split, update_attrs)
      assert title_split.split == "some updated split"
    end

    test "update_title_split/2 with invalid data returns error changeset" do
      title_split = title_split_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_title_split(title_split, @invalid_attrs)
      assert title_split == Media.get_title_split!(title_split.id)
    end

    test "delete_title_split/1 deletes the title_split" do
      title_split = title_split_fixture()
      assert {:ok, %TitleSplit{}} = Media.delete_title_split(title_split)
      assert_raise Ecto.NoResultsError, fn -> Media.get_title_split!(title_split.id) end
    end

    test "change_title_split/1 returns a title_split changeset" do
      title_split = title_split_fixture()
      assert %Ecto.Changeset{} = Media.change_title_split(title_split)
    end
  end
end
