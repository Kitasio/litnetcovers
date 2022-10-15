defmodule Litcovers.CharacterTest do
  use Litcovers.DataCase

  alias Litcovers.Character

  describe "eyes" do
    alias Litcovers.Character.Eye

    import Litcovers.CharacterFixtures

    @invalid_attrs %{color: nil, prompt: nil}

    test "list_eyes/0 returns all eyes" do
      eye = eye_fixture()
      assert Character.list_eyes() == [eye]
    end

    test "get_eye!/1 returns the eye with given id" do
      eye = eye_fixture()
      assert Character.get_eye!(eye.id) == eye
    end

    test "create_eye/1 with valid data creates a eye" do
      valid_attrs = %{color: "some color", prompt: "some prompt"}

      assert {:ok, %Eye{} = eye} = Character.create_eye(valid_attrs)
      assert eye.color == "some color"
      assert eye.prompt == "some prompt"
    end

    test "create_eye/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Character.create_eye(@invalid_attrs)
    end

    test "update_eye/2 with valid data updates the eye" do
      eye = eye_fixture()
      update_attrs = %{color: "some updated color", prompt: "some updated prompt"}

      assert {:ok, %Eye{} = eye} = Character.update_eye(eye, update_attrs)
      assert eye.color == "some updated color"
      assert eye.prompt == "some updated prompt"
    end

    test "update_eye/2 with invalid data returns error changeset" do
      eye = eye_fixture()
      assert {:error, %Ecto.Changeset{}} = Character.update_eye(eye, @invalid_attrs)
      assert eye == Character.get_eye!(eye.id)
    end

    test "delete_eye/1 deletes the eye" do
      eye = eye_fixture()
      assert {:ok, %Eye{}} = Character.delete_eye(eye)
      assert_raise Ecto.NoResultsError, fn -> Character.get_eye!(eye.id) end
    end

    test "change_eye/1 returns a eye changeset" do
      eye = eye_fixture()
      assert %Ecto.Changeset{} = Character.change_eye(eye)
    end
  end

  describe "hair" do
    alias Litcovers.Character.Hair

    import Litcovers.CharacterFixtures

    @invalid_attrs %{name: nil, prompt: nil}

    test "list_hair/0 returns all hair" do
      hair = hair_fixture()
      assert Character.list_hair() == [hair]
    end

    test "get_hair!/1 returns the hair with given id" do
      hair = hair_fixture()
      assert Character.get_hair!(hair.id) == hair
    end

    test "create_hair/1 with valid data creates a hair" do
      valid_attrs = %{name: "some name", prompt: "some prompt"}

      assert {:ok, %Hair{} = hair} = Character.create_hair(valid_attrs)
      assert hair.name == "some name"
      assert hair.prompt == "some prompt"
    end

    test "create_hair/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Character.create_hair(@invalid_attrs)
    end

    test "update_hair/2 with valid data updates the hair" do
      hair = hair_fixture()
      update_attrs = %{name: "some updated name", prompt: "some updated prompt"}

      assert {:ok, %Hair{} = hair} = Character.update_hair(hair, update_attrs)
      assert hair.name == "some updated name"
      assert hair.prompt == "some updated prompt"
    end

    test "update_hair/2 with invalid data returns error changeset" do
      hair = hair_fixture()
      assert {:error, %Ecto.Changeset{}} = Character.update_hair(hair, @invalid_attrs)
      assert hair == Character.get_hair!(hair.id)
    end

    test "delete_hair/1 deletes the hair" do
      hair = hair_fixture()
      assert {:ok, %Hair{}} = Character.delete_hair(hair)
      assert_raise Ecto.NoResultsError, fn -> Character.get_hair!(hair.id) end
    end

    test "change_hair/1 returns a hair changeset" do
      hair = hair_fixture()
      assert %Ecto.Changeset{} = Character.change_hair(hair)
    end
  end

  describe "celebs" do
    alias Litcovers.Character.Celeb

    import Litcovers.CharacterFixtures

    @invalid_attrs %{famous: nil, gender: nil, name: nil}

    test "list_celebs/0 returns all celebs" do
      celeb = celeb_fixture()
      assert Character.list_celebs() == [celeb]
    end

    test "get_celeb!/1 returns the celeb with given id" do
      celeb = celeb_fixture()
      assert Character.get_celeb!(celeb.id) == celeb
    end

    test "create_celeb/1 with valid data creates a celeb" do
      valid_attrs = %{famous: true, gender: :male, name: "some name"}

      assert {:ok, %Celeb{} = celeb} = Character.create_celeb(valid_attrs)
      assert celeb.famous == true
      assert celeb.gender == :male
      assert celeb.name == "some name"
    end

    test "create_celeb/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Character.create_celeb(@invalid_attrs)
    end

    test "update_celeb/2 with valid data updates the celeb" do
      celeb = celeb_fixture()
      update_attrs = %{famous: false, gender: :female, name: "some updated name"}

      assert {:ok, %Celeb{} = celeb} = Character.update_celeb(celeb, update_attrs)
      assert celeb.famous == false
      assert celeb.gender == :female
      assert celeb.name == "some updated name"
    end

    test "update_celeb/2 with invalid data returns error changeset" do
      celeb = celeb_fixture()
      assert {:error, %Ecto.Changeset{}} = Character.update_celeb(celeb, @invalid_attrs)
      assert celeb == Character.get_celeb!(celeb.id)
    end

    test "delete_celeb/1 deletes the celeb" do
      celeb = celeb_fixture()
      assert {:ok, %Celeb{}} = Character.delete_celeb(celeb)
      assert_raise Ecto.NoResultsError, fn -> Character.get_celeb!(celeb.id) end
    end

    test "change_celeb/1 returns a celeb changeset" do
      celeb = celeb_fixture()
      assert %Ecto.Changeset{} = Character.change_celeb(celeb)
    end
  end
end
