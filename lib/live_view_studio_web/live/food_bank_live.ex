defmodule LiveViewStudioWeb.FoodBankLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_, _, socket) do
    {:ok,
      socket,
      temporary_assigns: [donations: []]}
  end

  def handle_params(params, _, socket) do
    socket = if !Map.has_key?(socket.assigns, "total_donations") do
      assign(socket, total_donations: Donations.count_donations())
    end

    params = validate_params(params, socket.assigns.total_donations)

    paginate_options = %{page: params["page"], per_page: params["per_page"]}
    sort_options = %{sort_by: params["sort_by"], sort_order: params["sort_order"]}

    donations = Donations.list_donations(paginate: paginate_options, sort: sort_options)

    socket = assign(socket,
      donations: donations,
      options: Map.merge(paginate_options, sort_options)
    )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    options = Map.merge(socket.assigns.options, %{per_page: per_page})
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, options))}
  end

  defp validate_params(params, total_donations) do
    params = params
    |> Map.put("sort_by",
      param_or_first_permitted(params["sort_by"], ~w(item quantity days_until_expires)) |> String.to_atom()
    )
    |> Map.put("sort_order",
      param_or_first_permitted(params["sort_order"], ~w(asc desc)) |> String.to_atom()
    )
    |> Map.put("per_page",
      case params["per_page"] do
        "all" -> "all"
        _ -> case Integer.parse(params["per_page"] || "5") do
               {number, _} -> number
               :error -> 5
             end
      end
    )
    if params["per_page"] == "all" do
      Map.put(params, "page", 1)
    else
      max_pages = max_pages(total_donations, params["per_page"])
      Map.put(params, "page",
        case Integer.parse(params["page"] || "1") do
          {page, _} when page < 1 -> 1
          {page, _} when page > max_pages -> max_pages
          {page, _} -> page
          :error -> 1
        end
      )
    end
  end

  defp param_or_first_permitted(value, permitted) do
    if value in permitted, do: value, else: hd(permitted)
  end

  defp sort_link(socket, text, sort_by, options) do
    text = case options do
      %{sort_by: ^sort_by, sort_order: sort_order} -> text <> emoji(sort_order)
      _ -> text
    end
    sort_order = case options do
      %{sort_by: ^sort_by, sort_order: sort_order} -> toggle_sort_order(sort_order)
      _ -> :asc
    end
    options = Map.merge(options, %{sort_by: sort_by, sort_order: sort_order})
    live_patch(text, to: Routes.live_path(socket, __MODULE__, options))
  end

  defp pagination_link(socket, text, page, options, class) do
    options = Map.merge(options, %{page: page})
    live_patch(text, to: Routes.live_path(socket, __MODULE__, options), class: class)
  end

  defp expires_class(donation) do
    if Donations.almost_expired?(donation), do: "eat-now", else: "fresh"
  end

  defp max_pages(assigns), do: max_pages(assigns.total_donations, assigns.options.per_page)
  defp max_pages(total_donations, per_page), do: ceil(total_donations / per_page)

  defp toggle_sort_order(:asc), do: :desc
  defp toggle_sort_order(:desc), do: :asc

  defp emoji(:asc), do: "👆"
  defp emoji(:desc), do: "👇"
end