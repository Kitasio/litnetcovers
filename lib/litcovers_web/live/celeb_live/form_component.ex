defmodule LitcoversWeb.CelebLive.FormComponent do
  use LitcoversWeb, :live_component
  import Phoenix.Component

  alias Litcovers.Character

  @impl true
  def update(%{celeb: celeb} = assigns, socket) do
    changeset = Character.change_celeb(celeb)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"celeb" => celeb_params}, socket) do
    changeset =
      socket.assigns.celeb
      |> Character.change_celeb(celeb_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"celeb" => celeb_params}, socket) do
    save_celeb(socket, socket.assigns.action, celeb_params)
  end

  defp save_celeb(socket, :edit, celeb_params) do
    case Character.update_celeb(socket.assigns.celeb, celeb_params) do
      {:ok, _celeb} ->
        {:noreply,
         socket
         |> put_flash(:info, "Celeb updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_celeb(socket, :new, celeb_params) do
    case Character.create_celeb(celeb_params) do
      {:ok, _celeb} ->
        {:noreply,
         socket
         |> put_flash(:info, "Celeb created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
