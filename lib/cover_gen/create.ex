defmodule CoverGen.Create do
  alias Litcovers.Repo
  alias Litcovers.Media
  alias Litcovers.Media.Request

  alias CoverGen.OAI
  alias CoverGen.SD
  alias CoverGen.Overlay
  alias CoverGen.Helpers
  alias CoverGen.Spaces

  def new(%Request{} = request) do
    with _ <- ai_update_request(request, %{final_desc: request.description}),
         {:ok, ideas_list} <-
           OAI.description_to_cover_idea(
             request.description,
             request.prompt.type,
             request.character_gender,
             System.get_env("OAI_TOKEN")
           ),
         _ <- save_ideas(ideas_list, request),
         prompt <-
           Helpers.create_prompt(
             ideas_list |> Enum.random(),
             request.prompt.style_prompt,
             request.character_gender,
             request.prompt.type
           ),
         sd_params <-
           SD.get_sd_params(
             prompt,
             request.character_gender,
             request.prompt.type,
             1,
             request.width,
             request.height
           ),
         {:ok, sd_res} <-
           SD.diffuse(
             sd_params,
             System.get_env("REPLICATE_TOKEN")
           ) do
      %{"output" => image_list} = sd_res

      case Spaces.save_to_spaces(image_list) do
        {:error, reason} ->
          IO.inspect(reason)

        img_urls ->
          for url <- img_urls do
            image_params = %{"cover_url" => url, "prompt" => prompt}
            {:ok, _cover} = Media.create_cover(request, image_params)
          end

          {:ok, request} = ai_update_request(request, %{completed: true})

          broadcast(request, :gen_complete)
      end
    end
  end

  def more(%Request{} = request) do
    if request.ideas == [] do
      {:ok, ideas_list} =
        OAI.description_to_cover_idea(
          get_description(request),
          request.prompt.type,
          request.character_gender,
          System.get_env("OAI_TOKEN")
        )

      save_ideas(ideas_list, request)
    end

    %{idea: idea} = request.ideas |> Enum.random()

    with prompt <-
           Helpers.create_prompt(
             idea,
             request.prompt.style_prompt,
             request.character_gender,
             request.prompt.type
           ),
         {:ok, sd_res} <-
           SD.diffuse(
             prompt,
             request.character_gender,
             request.prompt.type,
             1,
             System.get_env("REPLICATE_TOKEN")
           ) do
      %{"output" => image_list} = sd_res

      case Spaces.save_to_spaces(image_list) do
        {:error, reason} ->
          IO.inspect(reason)

        img_urls ->
          for url <- img_urls do
            image_params = %{"cover_url" => url, "prompt" => prompt}
            {:ok, cover} = Media.create_cover(request, image_params)

            urls =
              Overlay.put_text_on_images(
                request.title |> Overlay.get_line_length_list(),
                cover.cover_url,
                request.author,
                request.title,
                request.prompt.realm |> to_string()
              )

            for url <- urls do
              Media.create_overlay(cover, %{url: url})
            end
          end

          request = Media.get_request_and_covers!(request.id)

          broadcast(request, :gen_complete)
      end
    end
  end

  def ai_update_request(%Request{} = request, attrs) do
    request
    |> Request.ai_changeset(attrs)
    |> Repo.update()
  end

  def save_ideas(ideas_list, request) do
    for idea <- ideas_list do
      idea = String.trim(idea)
      Media.create_idea(request, %{idea: idea})
    end
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Litcovers.PubSub, "generations")
  end

  defp broadcast(request, event) do
    Phoenix.PubSub.broadcast(Litcovers.PubSub, "generations", {event, request})
    {:ok, request}
  end

  defp get_description(request) do
    if request.final_desc == nil do
      request.description
    else
      request.final_desc
    end
  end
end
