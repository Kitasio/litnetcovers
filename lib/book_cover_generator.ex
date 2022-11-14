defmodule BookCoverGenerator do
  alias HTTPoison.Response
  require Elixir.Logger

  alias Litcovers.Character

  # Returns a prompt for stable diffusion
  def description_to_cover_idea(_description, _cover_type, _gender, nil),
    do: raise("OAI_TOKEN was not set\nVisit https://beta.openai.com/account/api-keys to get it")

  def description_to_cover_idea(description, cover_type, gender, oai_token) do
    # Set Open AI endpoint
    endpoint = "https://api.openai.com/v1/completions"

    # Set headers and options
    headers = [Authorization: "Bearer #{oai_token}", "Content-Type": "application/json"]
    options = [timeout: 50_000, recv_timeout: 50_000]

    # Append description to preamble
    prompt = description |> preamble(gender, cover_type)

    # Prepare params for Open AI
    oai_params = %OAIParams{prompt: prompt, temperature: 1}
    body = Jason.encode!(oai_params)

    Logger.info("Generatig idea with Open AI")
    # Send the post request
    case HTTPoison.post(endpoint, body, headers, options) do
      {:ok, %Response{body: res_body}} ->
        ideas = oai_response_text(res_body)
        {:ok, ideas}

      {:error, reason} ->
        Logger.error("Open AI gen idea failed, reason: #{reason}")
        {:error, :oai_failed}
    end
  end

  # Returns a list of image links
  def diffuse(_prompt, _amount, nil),
    do: raise("REPLICATE_TOKEN was not set\nVisit https://replicate.com/account to get it")

  def diffuse(prompt, amount, replicate_token) do
    sd_params = %SDParams{input: %{prompt: prompt, num_outputs: amount, height: 768}}

    body = Jason.encode!(sd_params)
    headers = [Authorization: "Token #{replicate_token}", "Content-Type": "application/json"]
    options = [timeout: 50_000, recv_timeout: 70_000]

    endpoint = "https://api.replicate.com/v1/predictions"

    Logger.info("Generating images with SD")

    case HTTPoison.post(endpoint, body, headers, options) do
      {:ok, %Response{body: res_body}} ->
        %{"urls" => %{"get" => generation_url}} = Jason.decode!(res_body)

        case check_for_output(generation_url, headers, options, 45) do
          {:ok, image_links} ->
            {:ok, image_links}

          {:error, reason} ->
            Logger.error("Stable diffusion image fetch failed, reason: #{reason}")
            {:error, reason}
        end

      {:error, reason} ->
        Logger.error("Stable diffusion post request failed, reason: #{reason}")
        {:error, reason}
    end
  end

  # def upscale(_image, nil),
  #   do: raise("REPLICATE_TOKEN was not set\nVisit https://replicate.com/account to get it")
  #
  # def upscale(image, replicate_token) do
  #   sd_params = %{
  #     version: "9d91795e944f3a585fa83f749617fc75821bea8b323348f39cf84f8fd0cbc2f7",
  #     input: %{image: image}
  #   }
  #
  #   body = Jason.encode!(sd_params)
  #   headers = [Authorization: "Token #{replicate_token}", "Content-Type": "application/json"]
  #   options = [timeout: 50_000, recv_timeout: 50_000]
  #
  #   endpoint = "https://api.replicate.com/v1/predictions"
  #
  #   case HTTPoison.post(endpoint, body, headers, options) do
  #     {:ok, %Response{body: res_body}} ->
  #       %{"urls" => %{"get" => generation_url}} = res_body |> Jason.decode!()
  #       check_for_output(generation_url, headers, options, 20)
  #
  #     {:error, _reason} ->
  #       {:error, :upscale_failed}
  #   end
  # end

  # Takes a list of image urls and saves them to DO spaces returning an imagekit url
  def save_to_spaces([]), do: []

  def save_to_spaces([url | img_list]) do
    Logger.info("Saving to spaces: #{url}")
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

      oai_params = %OAIParams{prompt: "Translate this to English:\n#{prompt}", temperature: 0.3}
      body = Jason.encode!(oai_params)

      case HTTPoison.post(endpoint, body, headers, options) do
        {:ok, %Response{body: res}} ->
          translation = oai_response_translation(res)
          {:ok, translation}

        {:error, reason} ->
          Logger.error("Failed to translate, reason: #{reason}")
          {:error, reason}
      end
    end
  end

  defp random_portrait do
    ["Side profile portrait", "Close up portrait", "Symmetrical face portrait"] |> Enum.random()
  end

  def create_prompt(idea_prompt, style_prompt, gender, :subject) do
    "#{random_portrait()}, #{idea_prompt}, #{get_character_prompt(gender)}, #{style_prompt}"
  end

  def create_prompt(idea_prompt, style_prompt, _gender, :object) do
    "#{idea_prompt}, #{style_prompt}"
  end

  defp is_english?(input) do
    input |> String.graphemes() |> List.first() |> byte_size() < 2
  end

  defp check_for_output(generation_url, headers, options, num_of_tries) do
    Logger.debug("Checking images, remaining tries: #{num_of_tries}")
    %Response{body: res} = HTTPoison.get!(generation_url, headers, options)
    res = res |> Jason.decode!()

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

  defp oai_response_translation(oai_res_body) do
    %{"choices" => choices_list} = Jason.decode!(oai_res_body)
    [%{"text" => text} | _] = choices_list

    text
    |> String.split("output:")
    |> List.last()
    |> String.trim()
  end

  defp oai_response_text(oai_res_body) do
    %{"choices" => choices_list} = Jason.decode!(oai_res_body)
    [%{"text" => text} | _] = choices_list

    text
    |> String.split("output:")
    |> List.last()
    |> String.trim()
    |> String.split("\n")
    |> List.first()
    |> String.split(",")
  end

  defp preamble(input, _gender, :object) do
    "Suggest a 4 book cover ideas, use objects and landscapes to describe it, separate ideas with commas

    Description: Time machine in the shape of a car accidentally sends our heroes from our modern world into the times of the wild west, into a small dusty cowboy town in the middle of the desert.
    Book cover ideas: Dusty wild west city of cowboys with a modern car in the middle of the street, bright white beams of light coming from the inside of a wild west saloon in the desert, a car tracks on the ground inside a wild west town street, A giant canyon with the old wild west city inside of it.

    Description: The story starts in nowadays London and than continues into majestic medieval fantasy hidden world of magic and wizarding, into the giant gothic castle with hundreds of secrets to be discovered.
    Book cover ideas: A giant magical gothic castle in the woods, A beautiful night castle with a lot of high towers hidden in the mist, A fantasy world with a giant castle made of stone, A giant hall of a medieval magical castle

    Description: The future world of high technologies isn’t bright - it’s cruel and ruthless. The story starts in the night club located in the heart of the futuristic megapolis.
    Book cover ideas: The night streets of a futuristic city, Cyberpunk night club party, Dirty high-tech night club interior, Abandoned bar inside a scyscrapper

    Description: #{input}
    Book cover ideas:"
  end

  defp preamble(input, "male", :subject) do
    "Suggest 4 book cover ideas, every idea depicts a man on some kind of background, separated by a comma

    Description: Old scientist with crazy sunglasses creates a time machine in a form of a car and travels back in time with his student, they try to change the future
    Book cover ideas: A scientist in a white coat inside of a high-tech mechanism, A handsome man wearing crazy glasses while traveling on a light speed in a cosmos, A mad professor and vivid blue electricity sparks everywhere around him, An attractive student with a dirty face inside of a car

    Description: The story of a vampire king from Transylvania, he ruled his kingdom for days, and drank people's blood at night
    Book cover ideas: A dark and handsome vampire with long hair in a dark gothic castle, A strong pale man wearing a long coat under the rain in a medieval city, A mysterious unknown in a dark hall of a castle, A dark prince with his face covered in blood on a bright red abstract background

    Description: #{input}
    Book cover ideas:"
  end

  defp preamble(input, "female", :subject) do
    "Suggest 4 book cover ideas, every idea depicts a woman located in some kind of a setting, separated by a comma

    Description: A student teenage girl moves into a new city and finds her life turned upside-down when she falls in love with a beautiful young vampire.
    Book cover ideas: Beautiful student in a dark grey forest, A vampire with a red glowing eyes iside a dark apartment, Passionate woman with a pale skin on a red abstract background, beautiful girl with her eyes closed on a dark misty field

    Description: A girl-archer living in a poor district of the future city is selected by lottery to compete in a televised battle royale to the death.
    Book cover ideas: A serious woman with a dirty face in a dark green forest, A strong young hero with scratches on her face with the explosion on the background, Protagonist with bright blue eyes hiding in the mysterious forest at night, A princess with a bow in a ruined city

    Description: #{input}
    Book cover ideas:"
  end

  defp preamble(input, _, _) do
    input
  end

  def get_celeb_name(gender, is_famous) do
    case Character.get_random_celeb(gender, is_famous) do
      nil ->
        ""

      celeb ->
        celeb.name
    end
  end

  def get_character_prompt(gender) do
    famous_celeb = get_celeb_name(gender, true)
    not_famous_celeb = get_celeb_name(gender, false)

    "#{not_famous_celeb} as #{famous_celeb}"
  end

  def insert_author_title(link, author, title, prompt_realm) do
    uri = link |> URI.parse()
    %URI{host: host, path: path} = uri

    {filename, list} = path |> String.split("/") |> List.pop_at(-1)
    bucket = list |> List.last()

    fonts = %{
      author_font: get_rand_type(prompt_realm, "author"),
      title_font: get_rand_type(prompt_realm, "title")
    }

    transformation = transformer(author, title, fonts)

    case host do
      "ik.imagekit.io" ->
        Path.join(["https://", host, bucket, transformation, filename])

      _ ->
        link
    end
  end

  def get_rand_type(prompt_realm, font_type) do
    %{^prompt_realm => %{^font_type => types}} = font_types()
    types |> Enum.random()
  end

  def transformer(author, title, fonts) do
    %{author_font: author_font, title_font: title_font} = fonts
    vinyetta = "tr:w-512,h-704,oi-vin.png,ow-512,oh-704"
    author_overlay = "ot-#{author},ots-24,otp-25_5_0_5,ofo-top,otc-fafafa,otf-#{author_font}.ttf"
    splits = title |> String.split("\n") |> Enum.reverse()

    font_path =
      if System.get_env("MIX_ENV") == "prod" do
        [Application.app_dir(:litcovers), "priv/static/fonts/#{title_font}.ttf"] |> Path.join()
      else
        "priv/static/fonts/#{title_font}.ttf"
      end

    font = %{
      name: title_font,
      metrics: TruetypeMetrics.load!(font_path)
    }

    title_overlay = create_title_overlay(splits, font, 10) |> Enum.join(":")
    Enum.join([vinyetta, author_overlay, title_overlay], ":")
  end

  def create_title_overlay([], _title_font, _pb), do: []

  def create_title_overlay([split | title_splits], font, pb) do
    %{name: font_name, metrics: font_metrics} = font
    split = String.upcase(split) |> String.trim()
    size = get_text_max_w(split, 12, 450, font_metrics)

    overlay = "ot-#{split},ots-#{size},ofo-bottom,otc-fafafa,otp-0_0_#{pb}_0,otf-#{font_name}.ttf"

    %{units_per_em: units_per_em, max_box: {_, _, _, y_max}} = font_metrics
    new_padding = (size * (y_max / units_per_em) + 5) |> ceil()

    [overlay | create_title_overlay(title_splits, font, pb + new_padding)]
  end

  def get_text_max_w(text, font_size, image_width, font_metrics) do
    width = FontMetrics.width(text, font_size, font_metrics)

    if width < image_width do
      get_text_max_w(text, font_size + 1, image_width, font_metrics)
    else
      trunc(font_size)
    end
  end

  def put_text_on_images([], _img_url, _author, _prompt_realm), do: []

  def put_text_on_images([title | splits_list], img_url, author, prompt_realm) do
    [
      insert_author_title(img_url, author, title, prompt_realm)
      | put_text_on_images(splits_list, img_url, author, prompt_realm)
    ]
  end

  defp whitespaces_num(str) do
    str |> String.graphemes() |> Enum.count(&(&1 == " "))
  end

  def title_splits_list(title) do
    title = String.replace(title, ",", "")

    cond do
      whitespaces_num(title) == 0 ->
        {:ok, [title]}

      whitespaces_num(title) == 1 ->
        {:ok, [title, title |> String.split(" ") |> Enum.join("\n")]}

      true ->
        case split_title(title, System.get_env("OAI_TOKEN")) do
          {:ok, splits} ->
            {:ok, splits}

          {:error, :oai_failed} ->
            {:error, :oai_failed}
        end
    end
  end

  # Returns a list of title splits
  def split_title(_title, nil),
    do: raise("OAI_TOKEN was not set\nVisit https://beta.openai.com/account/api-keys to get it")

  def split_title(title, oai_token) do
    # Removing commas
    title = String.replace(title, ",", "")

    # Set Open AI endpoint
    endpoint = "https://api.openai.com/v1/completions"

    # Set headers and options
    headers = [Authorization: "Bearer #{oai_token}", "Content-Type": "application/json"]
    options = [timeout: 50_000, recv_timeout: 50_000]

    # Append title to preamble
    prompt = title_split_preamble(title)

    # Prepare params for Open AI
    oai_params = %OAIParams{prompt: prompt, temperature: 0.3}
    body = Jason.encode!(oai_params)

    Logger.info("Splitting the title with Open AI")
    # Send the post request
    case HTTPoison.post(endpoint, body, headers, options) do
      {:ok, %Response{body: res_body}} ->
        splits = oai_split_res(res_body)
        {:ok, splits}

      {:error, reason} ->
        Logger.error("Open AI split title failed, reason: #{reason}")
        {:error, :oai_failed}
    end
  end

  defp oai_split_res(oai_res_body) do
    %{"choices" => choices_list} = Jason.decode!(oai_res_body)
    [%{"text" => text} | _] = choices_list

    text
    |> String.split("output:")
    |> List.last()
    |> String.trim()
    |> String.split(",")
  end

  defp title_split_preamble(title) do
    "break the book title if it makes sense:

    example: Harry Potter and the Goblet of Fire

    output: Harry Potter\nand the Goblet of Fire

    example: Нищенка в королевской академии магии

    output: Нищенка\nв королевской академии магии, Нищенка\nв королевской академии\nмагии

    example: Animal farm

    output: Animal farm, Animal\nfarm

    example: История Бессмертного-1 Поврежденный мир

    output: История Бессмертного-1\nПоврежденный мир, История Бессмертного-1\nПоврежденный\nмир, История\nБессмертного-1\nПоврежденный мир

    #{title}

    output:"
  end

  def font_types do
    %{
      "fantasy" => %{
        "author" => [
          "AttackType-Heavy",
          "BalkaraFreeCondensed-npoekmu.me",
          "DwarvenStonecraftCyr",
          "GarciaMarquez",
          "OrelegaOne-Regular",
          "Underdog-Regular"
        ],
        "title" => [
          "Ambidexter_Regular",
          "AttackType-Heavy",
          "BalkaraFreeCondensed-npoekmu.me",
          "Belozersk_Font",
          "DRUZHOK",
          "DwarvenStonecraftCyr",
          "FemmeFatale-Regular",
          "GarciaMarquez",
          "Germanica",
          "kurbanistika",
          "Mirra",
          "Ramp",
          "ST-Nizhegorodsky",
          "StalinistOne-Regular",
          "Stig",
          "Tsarevich_old",
          "Underdog-Regular"
        ]
      },
      "realism" => %{
        "author" => [
          "Comic_CAT",
          "DelaGothicOne-Regular",
          "Felidae",
          "Garet-Heavy",
          "Izax",
          "Sloval",
          "TT2020StyleB-Regular"
        ],
        "title" => [
          "Angry",
          "Comic_CAT",
          "DelaGothicOne-Regular",
          "Eleventh-Square",
          "Felidae",
          "Garet-Heavy",
          "Izax",
          "le-murmure",
          "Miratrix-Normal",
          "Molot",
          "NovitoNova-Regular",
          "Ouroboros-Regular",
          "Sloval",
          "tangak",
          "TT2020StyleB-Regular"
        ]
      },
      "futurism" => %{
        "author" => [
          "Aronder",
          "EBENYA",
          "Hellenica",
          "MoscowMetro",
          "Practice-font-Mono",
          "Radiotechnika"
        ],
        "title" => [
          "Aronder",
          "EBENYA",
          "forward",
          "Greybeard-22px-Bold",
          "Hellenica",
          "Kontanter-Bold",
          "MonHugo-in",
          "MoscowMetro",
          "Obrazec-2.0",
          "Polonium-Bold",
          "Practice-font-Mono",
          "Radiotechnika",
          "shinners-regular",
          "Snowstorm-Bold",
          "Yulong",
          "Zyablik-Regular"
        ]
      }
    }
  end
end
