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
end
