defmodule Tartupark.Router do
    use Tartupark.Web, :router

    pipeline :browser do
      plug :accepts, ["html"]
      plug :fetch_session
      plug :fetch_flash
      plug :protect_from_forgery
      plug :put_secure_browser_headers
      # plug Tartupark.Authentication, repo: Tartupark.Repo
    end

    ### lecture 10. taks.authentication silindi, bu elave edildi
    pipeline :browser_auth do
      plug Guardian.Plug.VerifySession
      plug Guardian.Plug.LoadResource
    end

    # pipeline :require_login do
    #   plug Guardian.Plug.EnsureAuthenticated, handler: Tartupark.SessionController
    #   plug :guardian_current_user
    # end

    def guardian_current_user(conn, _) do
      Plug.Conn.assign(conn, :current_user, Guardian.Plug.current_resource(conn))
    end
    ### son

    ### practice 9 - da edit edildi...
    #pipeline :api do
    #  plug :accepts, ["json"]
    #end

    ### lecture 10. scope hissesi tamam deyisdi...
    scope "/", Tartupark do
      pipe_through :browser # Use the default browser stack

    #   resources "/sessions", SessionController, only: [:new, :create]
    end

    scope "/", Tartupark do
      pipe_through [:browser,:browser_auth]

      get "/", PageController, :index
      resources "/users", UserController
    end

    ### practice 9
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
      post "/register", UserAPIController, :create
    end

    scope "/api", Tartupark do
      pipe_through [:api, :auth_api]

      post "/search", BookingAPIController, :search
      post "/bookings", BookingAPIController, :create
      patch "/bookings/:id", BookingAPIController, :update
      get "/bookings/summary", BookingAPIController, :index
      delete "/bookings/:id", BookingAPIController, :delete
      post "/payments", PaymentAPIController, :create
      delete "/sessions/:id", SessionAPIController, :delete
    end
  end
