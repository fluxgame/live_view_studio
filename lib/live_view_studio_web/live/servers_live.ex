defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_, _, socket) do
    servers = Servers.list_servers()
    socket = socket
    |> assign_selected_server(hd(servers))
    |> assign(servers: servers)
    {:ok, socket}
  end

  def handle_params(%{"id" => name}, _, socket) do
    server = Servers.get_server_by_name!(name)
    {:noreply, assign_selected_server(socket, server)}
  end

  def handle_params(_, _, socket) do
    socket = if socket.assigns.live_action == :new do
      assign(socket, selected_server: nil, changeset: Servers.change_server(%Server{}))
    else
      socket
    end
    {:noreply, socket}
  end

  def handle_event("save", %{"server" => params}, socket) do
    case Servers.create_server(params) do
      {:ok, server} ->
        socket = socket
        |> update(:servers, fn servers -> [server | servers] end)
        |> push_patch(to: Routes.live_path(socket, __MODULE__, id: server.name))
        :timer.sleep(500)
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp link_body(server) do
    assigns = %{name: server.name, status: server.status}

    ~L"""
    <span class="status <%= @status %>"></span>
    <img src="/images/server.svg" />
    <%= @name %>
    """
  end

  defp assign_selected_server(socket, server) do
    assign(socket, selected_server: server, page_title: server.name)
  end
end