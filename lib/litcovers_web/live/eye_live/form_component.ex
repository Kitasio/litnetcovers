defmodule LitcoversWeb.EyeLive.FormComponent do
  use LitcoversWeb, :live_component
  import Phoenix.Component

  alias Litcovers.Character

  @impl true
  def update(%{eye: eye} = assigns, socket) do
    changeset = Character.change_eye(eye)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"eye" => eye_params}, socket) do
    changeset =
      socket.assigns.eye
      |> Character.change_eye(eye_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"eye" => eye_params}, socket) do
    save_eye(socket, socket.assigns.action, eye_params)
  end

  defp save_eye(socket, :edit, eye_params) do
    case Character.update_eye(socket.assigns.eye, eye_params) do
      {:ok, _eye} ->
        {:noreply,
         socket
         |> put_flash(:info, "Eye updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_eye(socket, :new, eye_params) do
    case Character.create_eye(eye_params) do
      {:ok, _eye} ->
        {:noreply,
         socket
         |> put_flash(:info, "Eye created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
