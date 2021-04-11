defmodule LiveViewStudioWeb.LicenseLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Licenses
  import Number.Currency
  import Inflex

  def mount(_params, _session, socket) do
    if connected?(socket) do :timer.send_interval(1000, self(), :tick) end

    expiration_time = Timex.shift(Timex.now(), hours: 1)
    socket =
      assign(socket,
        seats: 2,
        amount: Licenses.calculate(2),
        expiration_time: expiration_time,
        time_remaining: time_remaining(expiration_time)
      )
    {:ok, socket}
  end

  def handle_event("update", %{"seats" => seats}, socket) do
    seats = String.to_integer(seats)
    {:noreply, assign(socket, seats: seats, amount: Licenses.calculate(seats))}
  end

  def handle_info(:tick, socket) do
    expiration_time = socket.assigns.expiration_time
    socket = assign(socket, time_remaining: time_remaining(expiration_time))
    {:noreply, socket}
  end

  defp time_remaining(expiration_time) do
    max(DateTime.diff(expiration_time, Timex.now()), 0)
  end

  defp format_time(time) do
    time
    |> Timex.Duration.from_seconds()
    |> Timex.format_duration(:humanized)
  end
end