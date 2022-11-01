defmodule Litcovers.Media do
  @moduledoc """
  The Media context.
  """

  import Ecto.Query, warn: false
  alias Litcovers.Repo

  alias Litcovers.Media.Request
  alias Litcovers.Accounts
  alias Litcovers.Sd

  @doc """
  Returns the list of requests.

  ## Examples

      iex> list_requests()
      [%Request{}, ...]

  """
  def list_requests do
    Request
    |> order_by_date_insert()
    |> Repo.all()
    |> Repo.preload([:user, :covers])
  end

  def list_completed_requests do
    Request
    |> order_by_date_insert()
    |> completed_query()
    |> with_final_desc()
    |> Repo.all()
    |> Repo.preload([:user, :prompt, :covers])
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
    |> order_by_date_insert()
    |> Repo.all()
    |> Repo.preload([:user, :prompt, :ideas, :title_splits, covers: [:overlays]])
  end

  defp order_by_date_insert(query) do
    from(r in query, order_by: [desc: r.inserted_at])
  end

  defp with_final_desc(query) do
    from(r in query, where: not is_nil(r.final_desc))
  end

  defp completed_query(query) do
    from(r in query, where: r.completed == true)
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
    |> Repo.preload([:user, :prompt, :ideas, :title_splits, covers: [:overlays]])
  end

  @doc """
  Creates a request.

  ## Examples

      iex> create_request(%{field: value})
      {:ok, %Request{}}

      iex> create_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_request(%Accounts.User{} = user, %Sd.Prompt{} = prompt, attrs \\ %{}) do
    %Request{}
    |> Request.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:prompt, prompt)
    |> Repo.insert()
  end

  def user_requests_amount(%Accounts.User{} = user) do
    Request
    |> user_requests_query(user)
    |> Repo.aggregate(:count)
  end

  def save_ideas(ideas_list, request) do
    for idea <- ideas_list do
      idea = String.trim(idea)
      create_idea(request, %{idea: idea})
    end
  end

  def save_splits(splits_list, request) do
    for split <- splits_list do
      split = String.trim(split)
      create_title_split(request, %{split: split})
    end
  end

  def get_splits([]), do: []

  def get_splits([title_split | title_splits]) do
    %{split: split} = title_split
    [split | get_splits(title_splits)]
  end

  def gen_more(request) do
    %{idea: idea} = request.ideas |> Enum.random()

    with prompt <-
           BookCoverGenerator.create_prompt(
             idea,
             request.prompt.style_prompt,
             request.character_gender,
             request.prompt.type
           ),
         {:ok, sd_res} <- BookCoverGenerator.diffuse(prompt, 1, System.get_env("REPLICATE_TOKEN")) do
      %{"output" => image_list} = sd_res

      case BookCoverGenerator.save_to_spaces(image_list) do
        {:error, reason} ->
          IO.inspect(reason)

        img_urls ->
          for url <- img_urls do
            image_params = %{"cover_url" => url, "prompt" => prompt}
            {:ok, cover} = create_cover(request, image_params)

            urls =
              BookCoverGenerator.put_text_on_images(
                request.title_splits |> get_splits(),
                cover.cover_url,
                request.author,
                request.prompt.realm |> to_string()
              )

            for url <- urls do
              create_overlay(cover, %{url: url})
            end
          end

          request = get_request_and_covers!(request.id)

          broadcast(request, :gen_complete)
      end
    end
  end

  def gen_covers(request) do
    with {:ok, english_desc} <-
           BookCoverGenerator.translate_to_english(
             request.description,
             System.get_env("OAI_TOKEN")
           ),
         _ <- ai_update_request(request, %{final_desc: english_desc}),
         {:ok, ideas_list} <-
           BookCoverGenerator.description_to_cover_idea(
             english_desc,
             request.prompt.type,
             request.character_gender,
             System.get_env("OAI_TOKEN")
           ),
         _ <- save_ideas(ideas_list, request),
         {:ok, splits} <- BookCoverGenerator.title_splits_list(request.title),
         _ <- save_splits(splits, request),
         prompt <-
           BookCoverGenerator.create_prompt(
             ideas_list |> Enum.random(),
             request.prompt.style_prompt,
             request.character_gender,
             request.prompt.type
           ),
         {:ok, sd_res} <-
           BookCoverGenerator.diffuse(prompt, 1, System.get_env("REPLICATE_TOKEN")) do
      %{"output" => image_list} = sd_res

      case BookCoverGenerator.save_to_spaces(image_list) do
        {:error, reason} ->
          IO.inspect(reason)

        img_urls ->
          for url <- img_urls do
            image_params = %{"cover_url" => url, "prompt" => prompt}
            {:ok, cover} = create_cover(request, image_params)

            urls =
              BookCoverGenerator.put_text_on_images(
                splits,
                cover.cover_url,
                request.author,
                request.prompt.realm |> to_string()
              )

            for url <- urls do
              create_overlay(cover, %{url: url})
            end
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
    %Cover{}
    |> Repo.preload([:overlays])
    |> Repo.all()
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

  def get_cover(id) do
    case Repo.get(Cover, id) |> Repo.preload(:overlays) do
      nil ->
        {:error, :not_found}

      cover ->
        {:ok, cover}
    end
  end

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

  alias Litcovers.Media.Overlay

  @doc """
  Returns the list of overlays.

  ## Examples

      iex> list_overlays()
      [%Overlay{}, ...]

  """
  def list_overlays do
    Repo.all(Overlay)
  end

  @doc """
  Gets a single overlay.

  Raises `Ecto.NoResultsError` if the Overlay does not exist.

  ## Examples

      iex> get_overlay!(123)
      %Overlay{}

      iex> get_overlay!(456)
      ** (Ecto.NoResultsError)

  """
  def get_overlay!(id), do: Repo.get!(Overlay, id)

  def get_overlay(id) do
    case Repo.get(Overlay, id) do
      nil ->
        {:error, :not_found}

      overlay ->
        {:ok, overlay}
    end
  end

  def get_overlay_of_cover(cover) do
    Overlay
    |> where_cover(cover)
    |> Repo.all()
  end

  defp where_cover(query, cover) do
    from(c in query, where: c.cover_id == ^cover.id)
  end

  @doc """
  Creates a overlay.

  ## Examples

      iex> create_overlay(%{field: value})
      {:ok, %Overlay{}}

      iex> create_overlay(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_overlay(%Cover{} = cover, attrs \\ %{}) do
    %Overlay{}
    |> Overlay.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:cover, cover)
    |> Repo.insert()
  end

  @doc """
  Updates a overlay.

  ## Examples

      iex> update_overlay(overlay, %{field: new_value})
      {:ok, %Overlay{}}

      iex> update_overlay(overlay, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_overlay(%Overlay{} = overlay, attrs) do
    overlay
    |> Overlay.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a overlay.

  ## Examples

      iex> delete_overlay(overlay)
      {:ok, %Overlay{}}

      iex> delete_overlay(overlay)
      {:error, %Ecto.Changeset{}}

  """
  def delete_overlay(%Overlay{} = overlay) do
    Repo.delete(overlay)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking overlay changes.

  ## Examples

      iex> change_overlay(overlay)
      %Ecto.Changeset{data: %Overlay{}}

  """
  def change_overlay(%Overlay{} = overlay, attrs \\ %{}) do
    Overlay.changeset(overlay, attrs)
  end

  alias Litcovers.Media.Idea

  @doc """
  Returns the list of ideas.

  ## Examples

      iex> list_ideas()
      [%Idea{}, ...]

  """
  def list_ideas do
    Repo.all(Idea)
  end

  @doc """
  Gets a single idea.

  Raises `Ecto.NoResultsError` if the Idea does not exist.

  ## Examples

      iex> get_idea!(123)
      %Idea{}

      iex> get_idea!(456)
      ** (Ecto.NoResultsError)

  """
  def get_idea!(id), do: Repo.get!(Idea, id)

  @doc """
  Creates a idea.

  ## Examples

      iex> create_idea(%{field: value})
      {:ok, %Idea{}}

      iex> create_idea(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_idea(%Request{} = request, attrs \\ %{}) do
    %Idea{}
    |> Idea.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:request, request)
    |> Repo.insert()
  end

  @doc """
  Updates a idea.

  ## Examples

      iex> update_idea(idea, %{field: new_value})
      {:ok, %Idea{}}

      iex> update_idea(idea, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_idea(%Idea{} = idea, attrs) do
    idea
    |> Idea.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a idea.

  ## Examples

      iex> delete_idea(idea)
      {:ok, %Idea{}}

      iex> delete_idea(idea)
      {:error, %Ecto.Changeset{}}

  """
  def delete_idea(%Idea{} = idea) do
    Repo.delete(idea)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking idea changes.

  ## Examples

      iex> change_idea(idea)
      %Ecto.Changeset{data: %Idea{}}

  """
  def change_idea(%Idea{} = idea, attrs \\ %{}) do
    Idea.changeset(idea, attrs)
  end

  alias Litcovers.Media.TitleSplit

  @doc """
  Returns the list of title_splits.

  ## Examples

      iex> list_title_splits()
      [%TitleSplit{}, ...]

  """
  def list_title_splits do
    Repo.all(TitleSplit)
  end

  @doc """
  Gets a single title_split.

  Raises `Ecto.NoResultsError` if the Title split does not exist.

  ## Examples

      iex> get_title_split!(123)
      %TitleSplit{}

      iex> get_title_split!(456)
      ** (Ecto.NoResultsError)

  """
  def get_title_split!(id), do: Repo.get!(TitleSplit, id)

  @doc """
  Creates a title_split.

  ## Examples

      iex> create_title_split(%{field: value})
      {:ok, %TitleSplit{}}

      iex> create_title_split(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_title_split(%Request{} = request, attrs \\ %{}) do
    %TitleSplit{}
    |> TitleSplit.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:request, request)
    |> Repo.insert()
  end

  @doc """
  Updates a title_split.

  ## Examples

      iex> update_title_split(title_split, %{field: new_value})
      {:ok, %TitleSplit{}}

      iex> update_title_split(title_split, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_title_split(%TitleSplit{} = title_split, attrs) do
    title_split
    |> TitleSplit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a title_split.

  ## Examples

      iex> delete_title_split(title_split)
      {:ok, %TitleSplit{}}

      iex> delete_title_split(title_split)
      {:error, %Ecto.Changeset{}}

  """
  def delete_title_split(%TitleSplit{} = title_split) do
    Repo.delete(title_split)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking title_split changes.

  ## Examples

      iex> change_title_split(title_split)
      %Ecto.Changeset{data: %TitleSplit{}}

  """
  def change_title_split(%TitleSplit{} = title_split, attrs \\ %{}) do
    TitleSplit.changeset(title_split, attrs)
  end
end
