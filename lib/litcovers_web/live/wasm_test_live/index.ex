defmodule LitcoversWeb.WasmTestLive.Index do
  use LitcoversWeb, :live_view
  alias Litcovers.Accounts

  def mount(%{"locale" => locale} = _params, session, socket) do
    img_url = "https://ik.imagekit.io/soulgenesis/6c97d4a8-fdf2-4fde-af82-43383ff33008.png"
    base64_img = img_url_to_base64(img_url)

    font_bytes = File.read!("priv/static/fonts/Angry.ttf")
    base64_font = font_bytes |> Base.encode64()

    {
      :ok,
      socket
      |> assign(
        current_user: Accounts.get_user_by_session_token(session["user_token"]),
        locale: locale,
        title: "Wasm page",
        images: [],
        img_url: img_url,
        base64_img: base64_img,
        author_font_base64: base64_font,
        title_font_base64: base64_font
      )
    }
  end

  def handle_event("create-cover", %{"img" => img}, socket) do
    IO.inspect(img)

    image_bytes =
      img
      |> String.split(",")
      |> List.last()
      |> Base.decode64!()

    img_url = CoverGen.Spaces.save_bytes(image_bytes)
    {:noreply, socket |> assign(images: [img_url | socket.assigns.images])}
  end

  def handle_event("set-image", %{"url" => url}, socket) do
    base64_img = img_url_to_base64(url)
    {:noreply, socket |> assign(base64_img: base64_img, img_url: url)}
  end

  def img_url_to_base64(url) do
    res = HTTPoison.get!(url)
    res.body |> Base.encode64()
  end
end
