defmodule LiveViewStudioWeb.SearchLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Stores
  alias LiveViewStudio.Cities

  def mount(_params, _session, socket) do
    socket = assign(socket, zip: "", city: "", stores: [], matches: [], loading: false)
    {:ok, socket, temporary_assigns: [stores: []]}
  end

  def handle_event("zip-search", %{"zip" => zip}, socket) do
    send(self(), {:run_zip_search, zip})
    {:noreply, assign(socket, zip: zip, stores: [], loading: true)}
  end

  def handle_event("city-search", %{"city" => city}, socket) do
    send(self(), {:run_city_search, city})
    {:noreply, assign(socket, city: city, stores: [], loading: true)}
  end

  def handle_event("suggest-city", %{"city" => prefix}, socket) do
    {:noreply, assign(socket, matches: Cities.suggest(prefix))}
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

  def handle_info({:run_city_search, city}, socket) do
    socket = case Stores.search_by_city(city) do
      [] -> socket
            |> put_flash(:info, "No stores in \"#{city}\"")
            |> assign(:stores, [])
      stores -> socket
                |> clear_flash()
                |> assign(:stores, stores)
    end

    {:noreply, assign(socket, loading: false)}
  end
end