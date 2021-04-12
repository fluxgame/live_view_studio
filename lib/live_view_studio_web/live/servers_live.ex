defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers

  def mount(_, _, socket) do
    servers = Servers.list_servers()
    {:ok, assign(socket, servers: servers, selected_server: hd(servers))}
  end

  def handle_params(%{"id" => name}, _, socket) do
    server = Servers.get_server_by_name!(name)
    {:noreply, assign(socket, selected_server: server, page_title: server.name)}
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  defp link_body(server) do
    assigns = %{name: server.name}

    ~L"""
    <img src="/images/server.svg" />
    <%= @name %>
    """
  end
end