defmodule Litcovers.Media do
  @moduledoc """
  The Media context.
  """

  import Ecto.Query, warn: false
  alias Litcovers.Repo

  alias Litcovers.Media.Request
  alias Litcovers.Accounts

  @doc """
  Returns the list of requests.

  ## Examples

      iex> list_requests()
      [%Request{}, ...]

  """
  def list_requests do
    Request
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def list_uncompleted_requests do
    Request
    |> uncompleted_query()
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def list_user_requests(%Accounts.User{} = user) do
    Request
    |> user_requests_query(user)
    |> Repo.all()
    |> Repo.preload(:covers)
  end

  defp uncompleted_query(query) do
    from(r in query, where: r.completed == false)
  end

  defp user_requests_query(query, %Accounts.User{id: user_id}) do
    from(r in query, where: r.user_id == ^user_id)
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

  def get_request_and_covers!(id) do
    Request
    |> Repo.get!(id)
    |> Repo.preload([:user, :covers])
  end

  @doc """
  Creates a request.

  ## Examples

      iex> create_request(%{field: value})
      {:ok, %Request{}}

      iex> create_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_request(%Accounts.User{} = user, attrs \\ %{}) do
    %Request{}
    |> Request.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def user_requests_amount(%Accounts.User{} = user) do
    Request
    |> user_requests_query(user)
    |> Repo.aggregate(:count)
  end

  def gen_covers(request) do
    with {:ok, english_desc} <-
           BookCoverGenerator.translate_to_english(
             request.description,
             System.get_env("OAI_TOKEN")
           ),
         {:ok, idea} <-
           BookCoverGenerator.description_to_cover_idea(
             english_desc,
             request.type,
             System.get_env("OAI_TOKEN")
           ),
         # change final_prompt to idea
         _ <- ai_update_request(request, %{final_prompt: idea}),
         prompt <- BookCoverGenerator.create_prompt(idea, request.style_prompt, request.type),
         {:ok, sd_res} <-
           BookCoverGenerator.diffuse(prompt, 4, System.get_env("REPLICATE_TOKEN")) do
      %{"output" => image_list} = sd_res

      case BookCoverGenerator.save_to_spaces(image_list) do
        {:error, reason} ->
          IO.inspect(reason)

        img_urls ->
          for url <- img_urls do
            image_params = %{"cover_url" => url}
            create_cover(request, image_params)
          end

          request = ai_update_request(request, %{completed: true})

          broadcast(request, :gen_complete)
      end
    end
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Litcovers.PubSub, "generations")
  end

  defp broadcast(request, event) do
    Phoenix.PubSub.broadcast(Litcovers.PubSub, "generations", {event, request})
    {:ok, request}
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

  def admin_update_request(%Request{} = request, attrs) do
    request
    |> Request.admin_changeset(attrs)
    |> Repo.update()
  end

  def ai_update_request(%Request{} = request, attrs) do
    request
    |> Request.ai_changeset(attrs)
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

  alias Litcovers.Media.Cover

  @doc """
  Returns the list of covers.

  ## Examples

      iex> list_covers()
      [%Cover{}, ...]

  """
  def list_covers do
    Repo.all(Cover)
  end

  @doc """
  Gets a single cover.

  Raises `Ecto.NoResultsError` if the Cover does not exist.

  ## Examples

      iex> get_cover!(123)
      %Cover{}

      iex> get_cover!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cover!(id), do: Repo.get!(Cover, id)

  @doc """
  Creates a cover.

  ## Examples

      iex> create_cover(%{field: value})
      {:ok, %Cover{}}

      iex> create_cover(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cover(%Request{} = request, attrs \\ %{}) do
    %Cover{}
    |> Cover.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:request, request)
    |> Repo.insert()
  end

  @doc """
  Updates a cover.

  ## Examples

      iex> update_cover(cover, %{field: new_value})
      {:ok, %Cover{}}

      iex> update_cover(cover, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cover(%Cover{} = cover, attrs) do
    cover
    |> Cover.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cover.

  ## Examples

      iex> delete_cover(cover)
      {:ok, %Cover{}}

      iex> delete_cover(cover)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cover(%Cover{} = cover) do
    Repo.delete(cover)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cover changes.

  ## Examples

      iex> change_cover(cover)
      %Ecto.Changeset{data: %Cover{}}

  """
  def change_cover(%Cover{} = cover, attrs \\ %{}) do
    Cover.changeset(cover, attrs)
  end
end
