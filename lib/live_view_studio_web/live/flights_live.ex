defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Flights

  def mount(_params, _session, socket) do
    {:ok, assign(socket, flight: "", flights: [], loading: false)}
  end

  def handle_event("flight-search", %{"flight" => flight}, socket) do
    send(self(), {:run_flight_search, flight})
    {:noreply, assign(socket, flight: flight, stores: [], loading: true)}
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

  defp format_time(time) do
    Timex.format!(time, "%b %d at %H:%M", :strftime)
  end
end