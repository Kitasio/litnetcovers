defmodule Overlay do
  @derive Jason.Encoder
  defstruct author_font: "Stig.ttf",
            title_font: "Ramp.ttf",
            title: "Title",
            author: "Author",
            image_url:
              "https://ik.imagekit.io/soulgenesis/61737fdd-987e-4314-b035-4edca8600c30.png",
            line_length: 16

  def request_overlay(%Overlay{} = params) do
    endpoint = "https://litcovers-api.fly.dev/overlay"
    body = Jason.encode!(params)
    headers = ["Content-Type": "application/json"]

    case HTTPoison.post!(endpoint, body, headers) do
      %HTTPoison.Response{status_code: 200, body: image_bytes} ->
        {:ok, image_bytes}

      %HTTPoison.Response{status_code: status_code, body: body} ->
        {:error, "Error: #{status_code} - #{body}"}
    end
  end
end
