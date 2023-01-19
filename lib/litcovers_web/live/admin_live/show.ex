defmodule LitcoversWeb.AdminLive.Show do
  use LitcoversWeb, :live_view
  import Phoenix.Component

  import LitcoversWeb.UiComponents
  alias Litcovers.Accounts
  alias Litcovers.Media
  alias CoverGen.Create

  def mount(params, session, socket) do
    if connected?(socket), do: CoverGen.Create.subscribe()
    %{"request_id" => request_id, "locale" => locale} = params
    request = Media.get_request_and_covers!(request_id)

    {
      :ok,
      socket
      |> assign(
        current_user: Accounts.get_user_by_session_token(session["user_token"]),
        changeset: Media.change_cover(%Litcovers.Media.Cover{}),
        request: request,
        locale: locale,
        title: "Request page"
      )
      |> allow_upload(:cover,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 5,
        max_file_size: 16_000_000
      )
    }
  end

  def handle_info({:gen_complete, request}, socket) do
    if request.id == socket.assigns.request.id do
      {:noreply, socket |> assign(request: request)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("gen_more", %{}, socket) do
    Task.start(fn ->
      Create.more(socket.assigns.request)
    end)

    {:noreply, socket}
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :cover, ref)}
  end

  def handle_event("save", %{"cover" => image_params}, socket) do
    uploaded_files = consume_images(socket)

    for url <- uploaded_files do
      image_params = %{image_params | "cover_url" => url}
      cover = save_image(socket, image_params)
      Media.create_overlay(cover, %{url: url})
    end

    {:noreply,
     socket
     |> push_redirect(to: ~p"/#{socket.assigns.locale}/admin/#{socket.assigns.request.id}")}
  end

  def handle_event("delete", %{"cover_id" => cover_id}, socket) do
    cover = Media.get_cover!(cover_id)
    Media.delete_cover(cover)

    request = Media.get_request_and_covers!(socket.assigns.request.id)

    {:noreply, assign(socket, request: request)}
  end

  def handle_event("toggle_complete", %{}, socket) do
    Media.admin_update_request(socket.assigns.request, %{
      completed: !socket.assigns.request.completed
    })

    request = Media.get_request_and_covers!(socket.assigns.request.id)

    {:noreply, assign(socket, request: request)}
  end

  def handle_event("toggle_overlay", %{"overlay_id" => overlay_id}, socket) do
    overlay = Media.get_overlay!(overlay_id)
    Media.update_overlay(overlay, %{selected: !overlay.selected})

    request = Media.get_request_and_covers!(socket.assigns.request.id)

    {:noreply, assign(socket, request: request)}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  defp save_image(socket, image_params) do
    case Media.create_cover(socket.assigns.request, image_params) do
      {:ok, cover} ->
        cover

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp consume_images(socket) do
    imagekit_url = Application.get_env(:litcovers, :imagekit_url)
    bucket = Application.get_env(:litcovers, :bucket)

    consume_uploaded_entries(socket, :cover, fn meta, entry ->
      filename = "#{entry.uuid}.#{ext(entry)}"
      file = File.read!(meta.path)

      ExAws.S3.put_object(bucket, filename, file)
      |> ExAws.request!()

      image_url = Path.join(imagekit_url, filename)
      {:ok, image_url}
    end)
  end

  defp ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end
end
