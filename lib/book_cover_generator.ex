defmodule BookCoverGenerator do
  alias HTTPoison.Response

  # Returns a prompt for stable diffusion
  def description_to_cover_idea(_prompt, nil),
    do: raise("OAI_TOKEN was not set\nVisit https://beta.openai.com/account/api-keys to get it")

  def description_to_cover_idea(prompt, oai_token) do
    IO.puts("Starting cover idea generation...")
    # Set Open AI endpoint
    endpoint = "https://api.openai.com/v1/completions"

    # Set headers and options
    headers = [Authorization: "Bearer #{oai_token}", "Content-Type": "application/json"]
    options = [timeout: 50_000, recv_timeout: 50_000]

    # Translates to English if needed
    prompt = prompt |> translate_to_english(endpoint, headers, options)

    # IO.puts("Translated text\n#{prompt}")

    # Append prompt to preamble
    prompt = prompt |> preamble()

    # Prepare params for Open AI
    oai_params = %OAIParams{prompt: prompt}
    body = Jason.encode!(oai_params)

    # Send the post request
    %Response{body: res_body} = HTTPoison.post!(endpoint, body, headers, options)

    # Parse the response body
    res_body
    |> oai_response_text()
  end

  # Returns a list of image links
  def diffuse(_prompt, _amount, nil),
    do: raise("REPLICATE_TOKEN was not set\nVisit https://replicate.com/account to get it")

  def diffuse(prompt, amount, replicate_token) do
    IO.puts("Starting stable diffusion...")

    sd_params = %SDParams{input: %{prompt: prompt, num_outputs: amount}}

    body = Jason.encode!(sd_params)
    headers = [Authorization: "Token #{replicate_token}", "Content-Type": "application/json"]
    options = [timeout: 50_000, recv_timeout: 50_000]

    endpoint = "https://api.replicate.com/v1/predictions"

    %Response{body: res_body} = HTTPoison.post!(endpoint, body, headers, options)
    %{"urls" => %{"get" => generation_url}} = res_body |> Jason.decode!()

    check_for_output(generation_url, headers, options, 20)
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

    %Response{body: res_body} = HTTPoison.post!(endpoint, body, headers, options)
    %{"urls" => %{"get" => generation_url}} = res_body |> Jason.decode!()

    check_for_output(generation_url, headers, options, 20)
  end

  # Takes a list of image urls and saves them to DO spaces returning an imagekit url
  def save_to_spaces([]), do: []

  def save_to_spaces([url | img_list]) do
    IO.puts("Saving #{url} to spaces...")
    options = [timeout: 50_000, recv_timeout: 50_000]

    imagekit_url = Application.get_env(:litcovers, :imagekit_url)
    bucket = Application.get_env(:litcovers, :bucket)

    %HTTPoison.Response{body: image_bytes} = HTTPoison.get!(url, [], options)
    filename = "#{Ecto.UUID.generate()}.png"

    ExAws.S3.put_object(bucket, filename, image_bytes)
    |> ExAws.request!()

    image_url = Path.join(imagekit_url, filename)
    [image_url | save_to_spaces(img_list)]
  end

  defp translate_to_english(prompt, endpoint, headers, options) do
    if is_english?(prompt) do
      prompt
    else
      IO.puts("Translating text...")
      oai_params = %OAIParams{prompt: "Translate this to English: \n#{prompt}"}
      body = Jason.encode!(oai_params)
      %Response{body: res_body} = HTTPoison.post!(endpoint, body, headers, options)
      res_body
    end
  end

  def is_english?(input) do
    input |> String.graphemes() |> List.first() |> byte_size() < 2
  end

  defp check_for_output(generation_url, headers, options, num_of_tries) do
    %Response{body: res} = HTTPoison.get!(generation_url, headers, options)
    # %{"output" => image_list} = res |> Jason.decode!()
    res = res |> Jason.decode!()
    IO.inspect(res["output"])

    case image_ready?(res["output"], num_of_tries) do
      false ->
        :timer.sleep(2000)
        check_for_output(generation_url, headers, options, num_of_tries - 1)

      true ->
        res
    end
  end

  defp image_ready?(image_list, num_of_tries) do
    cond do
      image_list == nil and num_of_tries > 0 ->
        false

      true ->
        true
    end
  end

  defp oai_response_text(oai_res_body) do
    %{"choices" => choices_list} = Jason.decode!(oai_res_body)
    [%{"text" => text} | _] = choices_list
    text |> String.split("output:") |> List.last() |> String.trim()
  end

  defp preamble(input) do
    "Suggest a book cover idea (avoid faces)

    styles: medieval, Banksy, Polish poster, Hajime Sorayama,  90’s blacklight poster, poster, high-tech, cyberpunk, vaporwave, alien, modern, ancient, futuristic, retro, realistic, dreamlike, funk art, abstract, pop art, impressionism, minimalism, noir, photorealism, octane render, unreal engine 5, holographic, graffiti, watercolor painting

    example: The Hunger Games; Dystopian, science fiction, drama, action; Mockingjay is about Katniss fighting in the rebellion against the Capitol, while also trying to save Peeta from being brainwashed. Gale becomes more ruthless and Katniss starts to doubt her feelings for him. Prim is killed in a bombing, Katniss kills Coin, and she and Peeta eventually have children.
    1. The overall vibe of the text is dark and serious.
    2. It is a novel about a young girl who is fighting in a rebellion against her government, and also trying to save her love from being brainwashed.

    output: a burning golden pin of a jay bird catching an arrow on a black background, photorealism

    example: Twilight; fantasy, melodrama, romance; Bella Swan turns 18, breaks up with Edward Cullen, and becomes depressed. She is then saved by Jacob Black and the Quileute werewolves and decides to become a vampire.
    1. The text has a dark and depressing tone.
    2. It is a vampire novel.

    output: a red ink watercolour with a howling wolf on a vinous round background, in a minimalist style

    example: The Game of Thrones; Political fiction, fantasy, magic; The novels take place in a fictional world with magic and dragons and in which seasons last for years and end unpredictably. The principal story chronicles the power struggle for the Iron Throne among the great Houses of Westeros.
    1. The text has a dark, medieval feel to it.
    2. It is a novel about a power struggle for the Iron Throne, and it is in the fantasy genre.

    output: an iron throne made of a thousand swords standing in a majestic throne room forged by the flames of the ancient dragon, in a medieval style

    example: Dune; science fiction, adventure, planetary; House Atreides is assigned to govern the planet Arrakis, which is the only source of the valuable spice substance. The Atreides are betrayed by their physician and killed, but Paul, their son, escapes into the desert and is accepted by the Fremen who believe him to be a messianic figure. Paul establishes himself as the new leader of Arrakis and wrests control of the Empire from the Emperor.
    1. The overall vibe of the text is one of hope and determination. 
    2. It belongs to the science fiction genre.

    output: a man walking in a distance on an endless dune with two suns above his head, one bigger than the other, minimalist flat illustration

    example: #{input}"
  end
end
