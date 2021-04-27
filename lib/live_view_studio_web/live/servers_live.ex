defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_, _, socket) do
    if connected?(socket), do: Servers.subscribe()
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
        |> push_patch(to: Routes.live_path(socket, __MODULE__, id: server.name))
        :timer.sleep(500)
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"server" => params}, socket) do
    changeset =
      %Server{}
      |> Servers.change_server(params)
      |> Map.put(:action, :insert)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    {:ok, server} = 
      Servers.get_server!(id)
      |> Servers.toggle_server_status()

    servers = Servers.list_servers()
    :timer.sleep(500)
    {:noreply, assign(socket, selected_server: server, servers: servers)}
  end

  def handle_info({:server_created, server}, socket) do
    socket = update(socket, :servers, fn servers -> [server | servers] end)
    {:noreply, socket}
  end

  def handle_info({:server_updated, server}, socket) do

    socket = 
      if server.id == socket.assigns.selected_server.id do
        assign(socket, selected_server: server)
      else
        socket
      end

    socket = update(socket, :servers, replace_by_id(server, socket.assigns.servers))
    {:noreply, socket}
  end

  defp replace_by_id(server, servers) do
    for s <- servers do
      case s.id == server.id do
        true -> server
        false -> s
      end
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
