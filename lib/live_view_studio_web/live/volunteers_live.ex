defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    if connected?(socket), do: Volunteers.subscribe()

    changeset = Volunteers.change_volunteer(%Volunteer{})
    volunteers = Volunteers.list_volunteers()
    socket = assign(socket, volunteers: volunteers, changeset: changeset)
    {:ok, socket, temporary_assigns: [volunteers: []]}
  end

  def handle_event("save", %{"volunteer" => params}, socket) do
    case Volunteers.create_volunteer(params) do
      {:ok, _volunteer} ->
        changeset = Volunteers.change_volunteer(%Volunteer{})
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"volunteer" => params}, socket) do
    changeset = 
      %Volunteer{}
      |> Volunteers.change_volunteer(params)
      |> Map.put(:action, :insert)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    Volunteers.get_volunteer!(id)
    |> Volunteers.toggle_volunteer_status()

    {:noreply, socket}
  end

  def handle_info({message, volunteer}, socket) do
    socket = if message in [:volunteer_updated, :volunteer_created] do
      update(socket, :volunteers, fn volunteers -> [volunteer | volunteers] end)
    end
    {:noreply, socket}
  end
end
