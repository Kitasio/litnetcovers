defmodule LitcoversWeb.HairLive.FormComponent do
  use LitcoversWeb, :live_component
  import Phoenix.Component

  alias Litcovers.Character

  @impl true
  def update(%{hair: hair} = assigns, socket) do
    changeset = Character.change_hair(hair)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"hair" => hair_params}, socket) do
    changeset =
      socket.assigns.hair
      |> Character.change_hair(hair_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"hair" => hair_params}, socket) do
    save_hair(socket, socket.assigns.action, hair_params)
  end

  defp save_hair(socket, :edit, hair_params) do
    case Character.update_hair(socket.assigns.hair, hair_params) do
      {:ok, _hair} ->
        {:noreply,
         socket
         |> put_flash(:info, "Hair updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_hair(socket, :new, hair_params) do
    case Character.create_hair(hair_params) do
      {:ok, _hair} ->
        {:noreply,
         socket
         |> put_flash(:info, "Hair created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
