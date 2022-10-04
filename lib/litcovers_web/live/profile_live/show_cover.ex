defmodule LitcoversWeb.ProfileLive.ShowCover do
  use LitcoversWeb, :live_view

  import LitcoversWeb.UiComponents
  alias Litcovers.Accounts
  alias Litcovers.Media

  def mount(params, session, socket) do
    %{"cover_id" => cover_id, "request_id" => request_id} = params
    cover = Media.get_cover!(cover_id)
    request = Media.get_request!(request_id)

    {
      :ok,
      socket
      |> assign(
        current_user: Accounts.get_user_by_session_token(session["user_token"]),
        cover: cover,
        request: request,
        vibrant_color: "fafafa",
        muted_color: "fafafa",
        title: "Выбор наложения текста"
      )
    }
  end

  def handle_event("set-colors", palette, socket) do
    %{"muted" => muted, "vibrant" => vibrant} = palette
    vibrant = String.split(vibrant, "#") |> List.last()
    muted = String.split(muted, "#") |> List.last()
    {:noreply, assign(socket, vibrant_color: vibrant, muted_color: muted)}
  end

  def transformations(link, author, title, vibrant_color, muted_color) do
    [
      basic: insert_author_title(link, author, title, vibrant_color, muted_color)
    ]
  end

  def get_text_max_w(text, font_size, image_width, font_metrics) do
    width = FontMetrics.width(text, font_size, font_metrics)
    if width < image_width do
      get_text_max_w(text, font_size + 1, image_width, font_metrics)
    else
      trunc(font_size)
    end
  end

  def insert_author_title(link, author, title, vibrant_color, muted_color) do
    uri = link |> URI.parse()
    %URI{host: host, path: path} = uri

    {filename, list} = path |> String.split("/") |> List.pop_at(-1)
    bucket = list |> List.last()

    title = String.upcase(title)

    font_metrics = TruetypeMetrics.load!("priv/static/fonts/AttackType-Heavy.ttf")
    transformation =
      "tr:w-512,h-704,oi-vin.png,ow-512,oh-704:ot-#{author},ots-#{get_text_max_w(author, 12, 500, font_metrics)},ofo-top,otc-fafafa,otf-AttackType-Heavy.ttf:ot-ПРИВЕТИКУС,ots-#{get_text_max_w("ПРИВЕТИКУС", 12, 498, font_metrics)},ofo-bottom,otc-fafafa,otf-AttackType-Heavy.ttf,otp-0_0_35_0:ot-БОЛЬШАЯ ТАКАЯ АКУЛА,otc-fafafa,ofo-bottom,otf-AttackType-Heavy.ttf,ots-#{get_text_max_w("БОЛЬШАЯ ТАКАЯ АКУЛА", 12, 498, font_metrics)}"

    case host do
      "ik.imagekit.io" ->
        Path.join(["https://", host, bucket, transformation, filename])

      _ ->
        link
    end
  end
end
