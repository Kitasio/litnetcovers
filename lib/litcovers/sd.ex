defmodule Litcovers.Sd do
  @moduledoc """
  The Sd context.
  """

  import Ecto.Query, warn: false
  alias Litcovers.Repo

  alias Litcovers.Sd.Prompt

  @doc """
  Returns the list of prompts.

  ## Examples

      iex> list_prompts()
      [%Prompt{}, ...]

  """
  def list_prompts do
    Prompt
    |> Repo.all()
  end

  def list_all_where(realm, sentiment, type) do
    Prompt
    |> where_realm_query(realm)
    |> where_sentiment_query(sentiment)
    |> where_type_query(type)
    |> Repo.all()
  end

  defp where_realm_query(query, nil), do: query

  defp where_realm_query(query, realm) do
    from(p in query, where: p.realm == ^realm)
  end

  defp where_sentiment_query(query, nil), do: query

  defp where_sentiment_query(query, sentiment) do
    from(p in query, where: p.sentiment == ^sentiment)
  end

  defp where_type_query(query, nil), do: query

  defp where_type_query(query, type) do
    from(p in query, where: p.type == ^type)
  end

  @doc """
  Gets a single prompt.

  Raises `Ecto.NoResultsError` if the Prompt does not exist.

  ## Examples

      iex> get_prompt!(123)
      %Prompt{}

      iex> get_prompt!(456)
      ** (Ecto.NoResultsError)

  """
  def get_prompt!(id), do: Repo.get!(Prompt, id)

  @doc """
  Creates a prompt.

  ## Examples

      iex> create_prompt(%{field: value})
      {:ok, %Prompt{}}

      iex> create_prompt(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prompt(attrs \\ %{}) do
    %Prompt{}
    |> Prompt.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a prompt.

  ## Examples

      iex> update_prompt(prompt, %{field: new_value})
      {:ok, %Prompt{}}

      iex> update_prompt(prompt, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_prompt(%Prompt{} = prompt, attrs) do
    prompt
    |> Prompt.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a prompt.

  ## Examples

      iex> delete_prompt(prompt)
      {:ok, %Prompt{}}

      iex> delete_prompt(prompt)
      {:error, %Ecto.Changeset{}}

  """
  def delete_prompt(%Prompt{} = prompt) do
    Repo.delete(prompt)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prompt changes.

  ## Examples

      iex> change_prompt(prompt)
      %Ecto.Changeset{data: %Prompt{}}

  """
  def change_prompt(%Prompt{} = prompt, attrs \\ %{}) do
    Prompt.changeset(prompt, attrs)
  end
end
