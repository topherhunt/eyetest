defmodule EyeTestWeb.Router do
  use EyeTestWeb, :router
  import EyeTestWeb.SessionPlugs, only: [load_current_user: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EyeTestWeb do
    pipe_through :browser

    get "/", PageController, :index

    scope "/auth" do
      # The Ueberauth login route redirects to Auth0's login page
      get "/login", AuthController, :login
      # Auth0 redirects back here after successful auth
      get "/login_callback", AuthController, :login_callback
      get "/logout", AuthController, :logout
      get "/force_login/:id", AuthController, :force_login
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", EyeTestWeb do
  #   pipe_through :api
  # end
end
