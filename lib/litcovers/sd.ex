defmodule Litcovers.Sd do
  @moduledoc """
  The Sd context.
  """

  import Ecto.Query, warn: false
  alias Litcovers.Repo

  alias Litcovers.Sd.Sentiment

  @doc """
  Returns the list of sentiments.

  ## Examples

      iex> list_sentiments()
      [%Sentiment{}, ...]

  """
  def list_sentiments do
    Repo.all(Sentiment)
  end

  @doc """
  Gets a single sentiment.

  Raises `Ecto.NoResultsError` if the Sentiment does not exist.

  ## Examples

      iex> get_sentiment!(123)
      %Sentiment{}

      iex> get_sentiment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sentiment!(id), do: Repo.get!(Sentiment, id)

  @doc """
  Creates a sentiment.

  ## Examples

      iex> create_sentiment(%{field: value})
      {:ok, %Sentiment{}}

      iex> create_sentiment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sentiment(attrs \\ %{}) do
    %Sentiment{}
    |> Sentiment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sentiment.

  ## Examples

      iex> update_sentiment(sentiment, %{field: new_value})
      {:ok, %Sentiment{}}

      iex> update_sentiment(sentiment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sentiment(%Sentiment{} = sentiment, attrs) do
    sentiment
    |> Sentiment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sentiment.

  ## Examples

      iex> delete_sentiment(sentiment)
      {:ok, %Sentiment{}}

      iex> delete_sentiment(sentiment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sentiment(%Sentiment{} = sentiment) do
    Repo.delete(sentiment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sentiment changes.

  ## Examples

      iex> change_sentiment(sentiment)
      %Ecto.Changeset{data: %Sentiment{}}

  """
  def change_sentiment(%Sentiment{} = sentiment, attrs \\ %{}) do
    Sentiment.changeset(sentiment, attrs)
  end

  alias Litcovers.Sd.Realm

  @doc """
  Returns the list of realms.

  ## Examples

      iex> list_realms()
      [%Realm{}, ...]

  """
  def list_realms do
    Repo.all(Realm)
  end

  @doc """
  Gets a single realm.

  Raises `Ecto.NoResultsError` if the Realm does not exist.

  ## Examples

      iex> get_realm!(123)
      %Realm{}

      iex> get_realm!(456)
      ** (Ecto.NoResultsError)

  """
  def get_realm!(id), do: Repo.get!(Realm, id)

  @doc """
  Creates a realm.

  ## Examples

      iex> create_realm(%{field: value})
      {:ok, %Realm{}}

      iex> create_realm(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_realm(attrs \\ %{}) do
    %Realm{}
    |> Realm.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a realm.

  ## Examples

      iex> update_realm(realm, %{field: new_value})
      {:ok, %Realm{}}

      iex> update_realm(realm, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_realm(%Realm{} = realm, attrs) do
    realm
    |> Realm.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a realm.

  ## Examples

      iex> delete_realm(realm)
      {:ok, %Realm{}}

      iex> delete_realm(realm)
      {:error, %Ecto.Changeset{}}

  """
  def delete_realm(%Realm{} = realm) do
    Repo.delete(realm)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking realm changes.

  ## Examples

      iex> change_realm(realm)
      %Ecto.Changeset{data: %Realm{}}

  """
  def change_realm(%Realm{} = realm, attrs \\ %{}) do
    Realm.changeset(realm, attrs)
  end
end
