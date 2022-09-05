defmodule Litcovers.Media do
  @moduledoc """
  The Media context.
  """

  import Ecto.Query, warn: false
  alias Litcovers.Repo

  alias Litcovers.Media.Request

  @doc """
  Returns the list of requests.

  ## Examples

      iex> list_requests()
      [%Request{}, ...]

  """
  def list_requests do
    Repo.all(Request)
  end

  @doc """
  Gets a single request.

  Raises `Ecto.NoResultsError` if the Request does not exist.

  ## Examples

      iex> get_request!(123)
      %Request{}

      iex> get_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_request!(id), do: Repo.get!(Request, id)

  @doc """
  Creates a request.

  ## Examples

      iex> create_request(%{field: value})
      {:ok, %Request{}}

      iex> create_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_request(attrs \\ %{}) do
    %Request{}
    |> Request.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a request.

  ## Examples

      iex> update_request(request, %{field: new_value})
      {:ok, %Request{}}

      iex> update_request(request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_request(%Request{} = request, attrs) do
    request
    |> Request.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a request.

  ## Examples

      iex> delete_request(request)
      {:ok, %Request{}}

      iex> delete_request(request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_request(%Request{} = request) do
    Repo.delete(request)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking request changes.

  ## Examples

      iex> change_request(request)
      %Ecto.Changeset{data: %Request{}}

  """
  def change_request(%Request{} = request, attrs \\ %{}) do
    Request.changeset(request, attrs)
  end

  alias Litcovers.Media.Placeholder

  @doc """
  Returns the list of placeholders.

  ## Examples

      iex> list_placeholders()
      [%Placeholder{}, ...]

  """
  def list_placeholders do
    Repo.all(Placeholder)
  end

  @doc """
  Gets a single placeholder.

  Raises `Ecto.NoResultsError` if the Placeholder does not exist.

  ## Examples

      iex> get_placeholder!(123)
      %Placeholder{}

      iex> get_placeholder!(456)
      ** (Ecto.NoResultsError)

  """
  def get_placeholder!(id), do: Repo.get!(Placeholder, id)

  def get_random_placeholder do
    Placeholder
    |> random_order_query()
    |> limit_query(1)
    |> Repo.all()
  end

  defp limit_query(query, amount) do
    from(p in query, limit: ^amount)
  end

  defp random_order_query(query) do
    from(p in query, order_by: fragment("RANDOM()"))
  end

  @doc """
  Creates a placeholder.

  ## Examples

      iex> create_placeholder(%{field: value})
      {:ok, %Placeholder{}}

      iex> create_placeholder(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_placeholder(attrs \\ %{}) do
    %Placeholder{}
    |> Placeholder.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a placeholder.

  ## Examples

      iex> update_placeholder(placeholder, %{field: new_value})
      {:ok, %Placeholder{}}

      iex> update_placeholder(placeholder, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_placeholder(%Placeholder{} = placeholder, attrs) do
    placeholder
    |> Placeholder.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a placeholder.

  ## Examples

      iex> delete_placeholder(placeholder)
      {:ok, %Placeholder{}}

      iex> delete_placeholder(placeholder)
      {:error, %Ecto.Changeset{}}

  """
  def delete_placeholder(%Placeholder{} = placeholder) do
    Repo.delete(placeholder)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking placeholder changes.

  ## Examples

      iex> change_placeholder(placeholder)
      %Ecto.Changeset{data: %Placeholder{}}

  """
  def change_placeholder(%Placeholder{} = placeholder, attrs \\ %{}) do
    Placeholder.changeset(placeholder, attrs)
  end
end
