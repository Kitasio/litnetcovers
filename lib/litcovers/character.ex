defmodule Litcovers.Character do
  @moduledoc """
  The Character context.
  """

  import Ecto.Query, warn: false
  alias Litcovers.Repo

  alias Litcovers.Character.Eye

  @doc """
  Returns the list of eyes.

  ## Examples

      iex> list_eyes()
      [%Eye{}, ...]

  """
  def list_eyes do
    Repo.all(Eye)
  end

  @doc """
  Gets a single eye.

  Raises `Ecto.NoResultsError` if the Eye does not exist.

  ## Examples

      iex> get_eye!(123)
      %Eye{}

      iex> get_eye!(456)
      ** (Ecto.NoResultsError)

  """
  def get_eye!(id), do: Repo.get!(Eye, id)

  @doc """
  Creates a eye.

  ## Examples

      iex> create_eye(%{field: value})
      {:ok, %Eye{}}

      iex> create_eye(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_eye(attrs \\ %{}) do
    %Eye{}
    |> Eye.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a eye.

  ## Examples

      iex> update_eye(eye, %{field: new_value})
      {:ok, %Eye{}}

      iex> update_eye(eye, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_eye(%Eye{} = eye, attrs) do
    eye
    |> Eye.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a eye.

  ## Examples

      iex> delete_eye(eye)
      {:ok, %Eye{}}

      iex> delete_eye(eye)
      {:error, %Ecto.Changeset{}}

  """
  def delete_eye(%Eye{} = eye) do
    Repo.delete(eye)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking eye changes.

  ## Examples

      iex> change_eye(eye)
      %Ecto.Changeset{data: %Eye{}}

  """
  def change_eye(%Eye{} = eye, attrs \\ %{}) do
    Eye.changeset(eye, attrs)
  end

  alias Litcovers.Character.Hair

  @doc """
  Returns the list of hair.

  ## Examples

      iex> list_hair()
      [%Hair{}, ...]

  """
  def list_hair do
    Repo.all(Hair)
  end

  @doc """
  Gets a single hair.

  Raises `Ecto.NoResultsError` if the Hair does not exist.

  ## Examples

      iex> get_hair!(123)
      %Hair{}

      iex> get_hair!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hair!(id), do: Repo.get!(Hair, id)

  @doc """
  Creates a hair.

  ## Examples

      iex> create_hair(%{field: value})
      {:ok, %Hair{}}

      iex> create_hair(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hair(attrs \\ %{}) do
    %Hair{}
    |> Hair.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a hair.

  ## Examples

      iex> update_hair(hair, %{field: new_value})
      {:ok, %Hair{}}

      iex> update_hair(hair, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_hair(%Hair{} = hair, attrs) do
    hair
    |> Hair.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a hair.

  ## Examples

      iex> delete_hair(hair)
      {:ok, %Hair{}}

      iex> delete_hair(hair)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hair(%Hair{} = hair) do
    Repo.delete(hair)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hair changes.

  ## Examples

      iex> change_hair(hair)
      %Ecto.Changeset{data: %Hair{}}

  """
  def change_hair(%Hair{} = hair, attrs \\ %{}) do
    Hair.changeset(hair, attrs)
  end

  alias Litcovers.Character.Celeb

  @doc """
  Returns the list of celebs.

  ## Examples

      iex> list_celebs()
      [%Celeb{}, ...]

  """
  def list_celebs do
    Repo.all(Celeb)
  end

  @doc """
  Gets a single celeb.

  Raises `Ecto.NoResultsError` if the Celeb does not exist.

  ## Examples

      iex> get_celeb!(123)
      %Celeb{}

      iex> get_celeb!(456)
      ** (Ecto.NoResultsError)

  """
  def get_celeb!(id), do: Repo.get!(Celeb, id)

  @doc """
  Creates a celeb.

  ## Examples

      iex> create_celeb(%{field: value})
      {:ok, %Celeb{}}

      iex> create_celeb(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_celeb(attrs \\ %{}) do
    %Celeb{}
    |> Celeb.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a celeb.

  ## Examples

      iex> update_celeb(celeb, %{field: new_value})
      {:ok, %Celeb{}}

      iex> update_celeb(celeb, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_celeb(%Celeb{} = celeb, attrs) do
    celeb
    |> Celeb.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a celeb.

  ## Examples

      iex> delete_celeb(celeb)
      {:ok, %Celeb{}}

      iex> delete_celeb(celeb)
      {:error, %Ecto.Changeset{}}

  """
  def delete_celeb(%Celeb{} = celeb) do
    Repo.delete(celeb)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking celeb changes.

  ## Examples

      iex> change_celeb(celeb)
      %Ecto.Changeset{data: %Celeb{}}

  """
  def change_celeb(%Celeb{} = celeb, attrs \\ %{}) do
    Celeb.changeset(celeb, attrs)
  end
end
