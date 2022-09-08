defmodule Litcovers.MediaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Litcovers.Media` context.
  """

  @doc """
  Generate a request.
  """
  def request_fixture(attrs \\ %{}) do
    {:ok, request} =
      attrs
      |> Enum.into(%{
        author: "some author",
        description: "some description",
        genre: "some genre",
        max: 42,
        status: "some status",
        title: "some title",
        vibe: "some vibe"
      })
      |> Litcovers.Media.create_request()

    request
  end

  @doc """
  Generate a placeholder.
  """
  def placeholder_fixture(attrs \\ %{}) do
    {:ok, placeholder} =
      attrs
      |> Enum.into(%{
        author: "some author",
        description: "some description",
        title: "some title",
        vibe: "some vibe"
      })
      |> Litcovers.Media.create_placeholder()

    placeholder
  end

  @doc """
  Generate a cover.
  """
  def cover_fixture(attrs \\ %{}) do
    {:ok, cover} =
      attrs
      |> Enum.into(%{
        cover_url: "some cover_url"
      })
      |> Litcovers.Media.create_cover()

    cover
  end
end
