# this defines the routes needed to administrate users' and userGroups' access rights
# to predefined resources
defmodule Dispatcher do

  use Plug.Router

  def start(_argv) do
    port = 80
    IO.puts "Starting Plug with Cowboy on port #{port}"
    Plug.Adapters.Cowboy.http __MODULE__, [], port: port
    :timer.sleep(:infinity)
  end

  plug Plug.Logger
  plug :match
  plug :dispatch

  match "/pipelines/*path" do
    Proxy.forward conn, path, "http://resource/pipelines/"
  end

  match "/steps/*path" do
    Proxy.forward conn, path, "http://resource/steps/"
  end

  match "/init-daemon/*path" do
    Proxy.forward conn, path, "http://initDaemon/"
  end

  match "/authenticatables/*path" do
    Proxy.forward conn, path, "http://resource/authenticatables"
  end

  match "/users/*path" do
    Proxy.forward conn, path, "http://resource/users/"
  end

  match "/user-groups/*path" do
    Proxy.forward conn, path, "http://resource/user-groups/"
  end

  match "/access-tokens/*path" do
    Proxy.forward conn, path, "http://resource/access-tokens/"
  end

  match "/grants/*path" do
    Proxy.forward conn, path, "http://resource/grants/"
  end

  match _ do
    send_resp( conn, 404, "Route not found" )
  end

end