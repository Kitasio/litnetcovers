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

  @doc """
  Generate a overlay.
  """
  def overlay_fixture(attrs \\ %{}) do
    {:ok, overlay} =
      attrs
      |> Enum.into(%{
        url: "some url"
      })
      |> Litcovers.Media.create_overlay()

    overlay
  end

  @doc """
  Generate a idea.
  """
  def idea_fixture(attrs \\ %{}) do
    {:ok, idea} =
      attrs
      |> Enum.into(%{
        idea: "some idea"
      })
      |> Litcovers.Media.create_idea()

    idea
  end

  @doc """
  Generate a title_split.
  """
  def title_split_fixture(attrs \\ %{}) do
    {:ok, title_split} =
      attrs
      |> Enum.into(%{
        split: "some split"
      })
      |> Litcovers.Media.create_title_split()

    title_split
  end
end
