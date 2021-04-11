defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Flights
  alias LiveViewStudio.Airports

  def mount(_params, _session, socket) do
    {:ok, assign(socket, flight: "", airport: "", flights: [], matches: [], loading: false)}
  end

  def handle_event("flight-search", %{"flight" => flight}, socket) do
    send(self(), {:run_flight_search, flight})
    {:noreply, assign(socket, flight: flight, flights: [], loading: true)}
  end

  def handle_info({:run_flight_search, flight}, socket) do
    socket = case Flights.search_by_number(flight) do
      [] -> socket
            |> put_flash(:info, "Flight number \"#{flight}\" not found.")
            |> assign(:flights, [])
      flights -> socket
                |> clear_flash()
                |> assign(:flights, flights)
    end

    {:noreply, assign(socket, loading: false)}
  end

  def handle_event("suggest-airport", %{"airport" => prefix}, socket) do
    {:noreply, assign(socket, matches: Airports.suggest(prefix))}
  end

  def handle_event("airport-search", %{"airport" => airport}, socket) do
    send(self(), {:run_airport_search, airport})
    {:noreply, assign(socket, airport: airport, flights: [], loading: true)}
  end

  def handle_info({:run_airport_search, airport}, socket) do
    socket = case Flights.search_by_airport(airport) do
      [] -> socket
            |> put_flash(:info, "No flights found from/to \"#{airport}\".")
            |> assign(:flights, [])
      flights -> socket
                 |> clear_flash()
                 |> assign(:flights, flights)
    end

    {:noreply, assign(socket, loading: false)}
  end

  defp format_time(time) do
    Timex.format!(time, "%b %d at %H:%M", :strftime)
  end
end