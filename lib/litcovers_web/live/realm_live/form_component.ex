defmodule LitcoversWeb.RealmLive.FormComponent do
  use LitcoversWeb, :live_component

  alias Litcovers.Sd

  @impl true
  def update(%{realm: realm} = assigns, socket) do
    changeset = Sd.change_realm(realm)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"realm" => realm_params}, socket) do
    changeset =
      socket.assigns.realm
      |> Sd.change_realm(realm_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"realm" => realm_params}, socket) do
    save_realm(socket, socket.assigns.action, realm_params)
  end

  defp save_realm(socket, :edit, realm_params) do
    case Sd.update_realm(socket.assigns.realm, realm_params) do
      {:ok, _realm} ->
        {:noreply,
         socket
         |> put_flash(:info, "Realm updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_realm(socket, :new, realm_params) do
    case Sd.create_realm(realm_params) do
      {:ok, _realm} ->
        {:noreply,
         socket
         |> put_flash(:info, "Realm created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
