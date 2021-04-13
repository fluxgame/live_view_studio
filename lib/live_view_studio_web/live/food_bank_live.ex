defmodule LiveViewStudioWeb.FoodBankLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_, _, socket) do
    {:ok,
      assign(socket, total_donations: Donations.count_donations()),
      temporary_assigns: [donations: []]}
  end

  def handle_params(params, _, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = case params["per_page"] do
      "all" -> params["per_page"]
      _ -> String.to_integer(params["per_page"] || "5")
    end
#    per_page = String.to_integer(params["per_page"] || "5")

    paginate_options = %{page: page, per_page: per_page}
    donations = Donations.list_donations(paginate: paginate_options)

    socket = assign(socket,
      donations: donations,
      options: paginate_options
    )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    socket = push_patch(socket,
      to: Routes.live_path(
        socket,
        __MODULE__,
        page: socket.assigns.options.page,
        per_page: per_page
      )
    )
    {:noreply, socket}
  end

  defp pagination_link(socket, text, page, per_page, class) do
    live_patch text, to: Routes.live_path(socket, __MODULE__, page: page, per_page: per_page), class: class
  end

  defp expires_class(donation) do
    if Donations.almost_expired?(donation), do: "eat-now", else: "fresh"
  end
end