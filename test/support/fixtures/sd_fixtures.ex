defmodule Litcovers.SdFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Litcovers.Sd` context.
  """

  @doc """
  Generate a sentiment.
  """
  def sentiment_fixture(attrs \\ %{}) do
    {:ok, sentiment} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> Litcovers.Sd.create_sentiment()

    sentiment
  end

  @doc """
  Generate a realm.
  """
  def realm_fixture(attrs \\ %{}) do
    {:ok, realm} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> Litcovers.Sd.create_realm()

    realm
  end

  @doc """
  Generate a type.
  """
  def type_fixture(attrs \\ %{}) do
    {:ok, type} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> Litcovers.Sd.create_type()

    type
  end
end
