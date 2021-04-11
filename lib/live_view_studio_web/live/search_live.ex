defmodule LiveViewStudioWeb.SearchLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Stores

  def mount(_params, _session, socket) do
    {:ok, assign(socket, zip: "", stores: [], loading: false)}
  end

  def handle_event("zip-search", %{"zip" => zip}, socket) do
    send(self(), {:run_zip_search, zip})
    {:noreply, assign(socket, zip: zip, stores: [], loading: true)}
  end

  def handle_info({:run_zip_search, zip}, socket) do
    socket = case Stores.search_by_zip(zip) do
      [] -> socket
            |> put_flash(:info, "No stores in zip code \"#{zip}\"")
            |> assign(:stores, [])
      stores -> socket
                |> clear_flash()
                |> assign(:stores, stores)
    end

    {:noreply, assign(socket, loading: false)}
  end
end