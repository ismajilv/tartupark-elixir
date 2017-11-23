defmodule Tartupark.Router do
  use Tartupark.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  def guardian_current_user(conn, _) do
    Plug.Conn.assign(conn, :current_user, Guardian.Plug.current_resource(conn))
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Tartupark do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Tartupark do
  #   pipe_through :api
  # end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  pipeline :auth_api do
    plug Guardian.Plug.EnsureAuthenticated, handler: Tartupark.SessionAPIController
    plug :guardian_current_user
  end

  scope "/api", Tartupark do
    pipe_through :api
    post "/sessions", SessionAPIController, :create
  end

  scope "/api", Tartupark do
    pipe_through [:api, :auth_api]
    delete "/sessions/:id", SessionAPIController, :delete
    post "/bookings", BookingAPIController, :create
    patch "/bookings/:id", BookingAPIController, :update
  end
end
