defmodule BookCoverGenerator do
  alias HTTPoison.Response

  # Returns a prompt for stable diffusion
  def description_to_cover_idea(_description, _cover_type, nil),
    do: raise("OAI_TOKEN was not set\nVisit https://beta.openai.com/account/api-keys to get it")

  def description_to_cover_idea(description, cover_type, oai_token) do
    IO.puts("Starting cover idea generation...")
    # Set Open AI endpoint
    endpoint = "https://api.openai.com/v1/completions"

    # Set headers and options
    headers = [Authorization: "Bearer #{oai_token}", "Content-Type": "application/json"]
    options = [timeout: 50_000, recv_timeout: 50_000]

    # Append description to preamble
    prompt = description |> preamble(cover_type)

    # Prepare params for Open AI
    oai_params = %OAIParams{prompt: prompt}
    body = Jason.encode!(oai_params)

    # Send the post request
    case HTTPoison.post(endpoint, body, headers, options) do
      {:ok, %Response{body: res_body}} ->
        idea = oai_response_text(res_body)
        {:ok, idea}

      {:error, reason} ->
        IO.inspect(reason, label: "TODO: log the reason")
        {:error, :oai_failed}
    end
  end

  # Returns a list of image links
  def diffuse(_prompt, _amount, nil),
    do: raise("REPLICATE_TOKEN was not set\nVisit https://replicate.com/account to get it")

  def diffuse(prompt, amount, replicate_token) do
    IO.puts("Starting stable diffusion...")

    sd_params = %SDParams{input: %{prompt: prompt, num_outputs: amount, height: 768}}

    body = Jason.encode!(sd_params)
    headers = [Authorization: "Token #{replicate_token}", "Content-Type": "application/json"]
    options = [timeout: 50_000, recv_timeout: 50_000]

    endpoint = "https://api.replicate.com/v1/predictions"

    case HTTPoison.post(endpoint, body, headers, options) do
      {:ok, %Response{body: res_body}} ->
        %{"urls" => %{"get" => generation_url}} = Jason.decode!(res_body)

        case check_for_output(generation_url, headers, options, 25) do
          {:ok, image_links} ->
            {:ok, image_links}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def upscale(_image, nil),
    do: raise("REPLICATE_TOKEN was not set\nVisit https://replicate.com/account to get it")

  def upscale(image, replicate_token) do
    IO.puts("Starting the upscale...")

    sd_params = %{
      version: "9d91795e944f3a585fa83f749617fc75821bea8b323348f39cf84f8fd0cbc2f7",
      input: %{image: image}
    }

    body = Jason.encode!(sd_params)
    headers = [Authorization: "Token #{replicate_token}", "Content-Type": "application/json"]
    options = [timeout: 50_000, recv_timeout: 50_000]

    endpoint = "https://api.replicate.com/v1/predictions"

    case HTTPoison.post(endpoint, body, headers, options) do
      {:ok, %Response{body: res_body}} ->
        %{"urls" => %{"get" => generation_url}} = res_body |> Jason.decode!()
        check_for_output(generation_url, headers, options, 20)

      {:error, _reason} ->
        {:error, :upscale_failed}
    end
  end

  # Takes a list of image urls and saves them to DO spaces returning an imagekit url
  def save_to_spaces([]), do: []

  def save_to_spaces([url | img_list]) do
    IO.puts("Saving #{url} to spaces...")
    options = [timeout: 50_000, recv_timeout: 50_000]

    imagekit_url = Application.get_env(:litcovers, :imagekit_url)
    bucket = Application.get_env(:litcovers, :bucket)
    filename = "#{Ecto.UUID.generate()}.png"

    case HTTPoison.get(url, [], options) do
      {:error, reason} ->
        {:error, reason}

      {:ok, %HTTPoison.Response{body: image_bytes}} ->
        ExAws.S3.put_object(bucket, filename, image_bytes) |> ExAws.request!()

        image_url = Path.join(imagekit_url, filename)
        [image_url | save_to_spaces(img_list)]
    end
  end

  def translate_to_english(prompt, oai_token) do
    if is_english?(prompt) do
      {:ok, prompt}
    else
      # Set Open AI endpoint
      endpoint = "https://api.openai.com/v1/completions"

      # Set headers and options
      headers = [Authorization: "Bearer #{oai_token}", "Content-Type": "application/json"]
      options = [timeout: 50_000, recv_timeout: 50_000]

      IO.puts("Translating text...")
      oai_params = %OAIParams{prompt: "Translate this to English:\n#{prompt}"}
      body = Jason.encode!(oai_params)

      case HTTPoison.post(endpoint, body, headers, options) do
        {:ok, %Response{body: res}} ->
          translation = oai_response_text(res)
          {:ok, translation}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  def create_prompt(idea_prompt, style_prompt, :object) do
    "#{idea_prompt}, #{style_prompt}"
  end

  defp is_english?(input) do
    input |> String.graphemes() |> List.first() |> byte_size() < 2
  end

  defp check_for_output(generation_url, headers, options, num_of_tries) do
    %Response{body: res} = HTTPoison.get!(generation_url, headers, options)
    # %{"output" => image_list} = res |> Jason.decode!()
    res = res |> Jason.decode!()
    IO.inspect(res["output"])

    case check_image(res["output"], num_of_tries) do
      {:error, :out_of_tries} ->
        {:error, :out_of_tries}

      {:error, :not_ready} ->
        :timer.sleep(2000)
        check_for_output(generation_url, headers, options, num_of_tries - 1)

      {:ok, :ready} ->
        {:ok, res}
    end
  end

  defp check_image(_image_list, num_of_tries) when num_of_tries <= 0, do: {:error, :out_of_tries}
  defp check_image(nil, _num_of_tries), do: {:error, :not_ready}
  defp check_image(_image_list, _num_of_tries), do: {:ok, :ready}

  defp oai_response_text(oai_res_body) do
    %{"choices" => choices_list} = Jason.decode!(oai_res_body)
    [%{"text" => text} | _] = choices_list
    text |> String.split("output:") |> List.last() |> String.trim()
  end

  defp preamble(input, :object) do
    "Suggest a book cover idea, use objects and landscapes to describe the idea (avoid depicting people)

    Description: The speaker goes to the urologist, but is so distracted by the beauty of the therapist that he doesn't realize he's in the wrong room. He falls in love with her at first sight, but discovers that she doesn't like rich, domineering men. He decides to become a bioenergotherapist himself in order to win her over.
    Book cover: A red high heel shoe

    Description: Katya is a simple girl from a dysfunctional family who falls in love with a wealthy and powerful man. However, he is married and she has principles, so she is torn about what to do. The boss is not willing to let her go and she is not willing to submit, so the situation is fraught with tension.
    Book cover: A tie and wedding ring

    Description: #{input}
    Book cover:"
  end

  defp preamble(input, _) do
    input
  end
end
