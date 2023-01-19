defmodule CoverGen.SD do
  alias CoverGen.SD
  alias HTTPoison.Response
  require Elixir.Logger

  @derive Jason.Encoder
  defstruct version: "9936c2001faa2194a261c01381f90e65261879985476014a0a37a334593a05eb",
            input: %{
              prompt: "multicolor hyperspace",
              width: 512,
              height: 768,
              num_outputs: 1
            }

  def get_sd_params(prompt, gender, type, amount, width, height) do
    %SD{
      version: get_version(type, gender),
      input: %{
        prompt: prompt,
        width: width,
        height: height,
        num_outputs: amount
      }
    }
  end

  # Returns a list of image links
  def diffuse(_prompt, _amount, nil),
    do: raise("REPLICATE_TOKEN was not set\nVisit https://replicate.com/account to get it")

  def diffuse(sd_params, replicate_token) do
    body = Jason.encode!(sd_params)
    headers = [Authorization: "Token #{replicate_token}", "Content-Type": "application/json"]
    options = [timeout: 50_000, recv_timeout: 165_000]

    endpoint = "https://api.replicate.com/v1/predictions"

    Logger.info("Generating images with SD")

    case HTTPoison.post(endpoint, body, headers, options) do
      {:ok, %Response{body: res_body}} ->
        %{"urls" => %{"get" => generation_url}} = Jason.decode!(res_body)

        case check_for_output(generation_url, headers, options, 50) do
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

  defp get_version(_type, "couple") do
    "139abcbafe063bd8569836fbc97913ff9d0db1308a93e6f9a2a4d7d721008b9c"
  end

  defp get_version(type, _gender) do
    case type do
      :object ->
        "8abccf52e7cba9f6e82317253f4a3549082e966db5584e92c808ece132037776"

      :subject ->
        "9936c2001faa2194a261c01381f90e65261879985476014a0a37a334593a05eb"

      _ ->
        "9936c2001faa2194a261c01381f90e65261879985476014a0a37a334593a05eb"
    end
  end

  defp check_for_output(generation_url, headers, options, num_of_tries) do
    Logger.debug("Checking images, remaining tries: #{num_of_tries}")
    %Response{body: res} = HTTPoison.get!(generation_url, headers, options)
    res = res |> Jason.decode!()

    case check_image(res["output"], num_of_tries) do
      {:error, :out_of_tries} ->
        {:error, :out_of_tries}

      {:ok, :not_ready} ->
        :timer.sleep(2000)
        check_for_output(generation_url, headers, options, num_of_tries - 1)

      {:ok, :not_ready_slower} ->
        :timer.sleep(15000)
        check_for_output(generation_url, headers, options, num_of_tries - 1)

      {:ok, :ready} ->
        {:ok, res}
    end
  end

  defp check_image(_image_list, num_of_tries) when num_of_tries <= 0, do: {:error, :out_of_tries}
  defp check_image(nil, num_of_tries) when num_of_tries <= 5, do: {:ok, :not_ready_slower}
  defp check_image(nil, _num_of_tries), do: {:ok, :not_ready}
  defp check_image(_image_list, _num_of_tries), do: {:ok, :ready}
end
