defmodule LitcoversWeb.TypeLive.FormComponent do
  use LitcoversWeb, :live_component

  alias Litcovers.Sd

  @impl true
  def update(%{type: type} = assigns, socket) do
    changeset = Sd.change_type(type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"type" => type_params}, socket) do
    changeset =
      socket.assigns.type
      |> Sd.change_type(type_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"type" => type_params}, socket) do
    save_type(socket, socket.assigns.action, type_params)
  end

  defp save_type(socket, :edit, type_params) do
    case Sd.update_type(socket.assigns.type, type_params) do
      {:ok, _type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Type updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_type(socket, :new, type_params) do
    case Sd.create_type(type_params) do
      {:ok, _type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Type created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
