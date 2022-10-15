defmodule Litcovers.CharacterFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Litcovers.Character` context.
  """

  @doc """
  Generate a eye.
  """
  def eye_fixture(attrs \\ %{}) do
    {:ok, eye} =
      attrs
      |> Enum.into(%{
        color: "some color",
        prompt: "some prompt"
      })
      |> Litcovers.Character.create_eye()

    eye
  end

  @doc """
  Generate a hair.
  """
  def hair_fixture(attrs \\ %{}) do
    {:ok, hair} =
      attrs
      |> Enum.into(%{
        name: "some name",
        prompt: "some prompt"
      })
      |> Litcovers.Character.create_hair()

    hair
  end

  @doc """
  Generate a celeb.
  """
  def celeb_fixture(attrs \\ %{}) do
    {:ok, celeb} =
      attrs
      |> Enum.into(%{
        famous: true,
        gender: :male,
        name: "some name"
      })
      |> Litcovers.Character.create_celeb()

    celeb
  end
end
