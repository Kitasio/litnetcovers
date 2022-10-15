defmodule LitcoversWeb.Router do
  use LitcoversWeb, :router

  import LitcoversWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LitcoversWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LitcoversWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", LitcoversWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LitcoversWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/admin", LitcoversWeb do
    pipe_through [:browser, :require_authenticated_admin]

    resources "/placeholders", PlaceholderController

    live "/", AdminLive.Index

    live "/prompts", PromptLive.Index, :index
    live "/prompts/new", PromptLive.Index, :new
    live "/prompts/:id/edit", PromptLive.Index, :edit

    live "/prompts/:id", PromptLive.Show, :show
    live "/prompts/:id/show/edit", PromptLive.Show, :edit

    live "/eyes", EyeLive.Index, :index
    live "/eyes/new", EyeLive.Index, :new
    live "/eyes/:id/edit", EyeLive.Index, :edit

    live "/eyes/:id", EyeLive.Show, :show
    live "/eyes/:id/show/edit", EyeLive.Show, :edit

    live "/hair", HairLive.Index, :index
    live "/hair/new", HairLive.Index, :new
    live "/hair/:id/edit", HairLive.Index, :edit

    live "/hair/:id", HairLive.Show, :show
    live "/hair/:id/show/edit", HairLive.Show, :edit

    live "/celebs", CelebLive.Index, :index
    live "/celebs/new", CelebLive.Index, :new
    live "/celebs/:id/edit", CelebLive.Index, :edit

    live "/celebs/:id", CelebLive.Show, :show
    live "/celebs/:id/show/edit", CelebLive.Show, :edit

    live "/:request_id", AdminLive.Show
  end

  scope "/", LitcoversWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", LitcoversWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/requests", RequestController
    live "/request", RequestsLive.Index

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    live "/profile", ProfileLive.Index
    live "/profile/:request_id", ProfileLive.Show
    live "/profile/:request_id/:cover_id", ProfileLive.ShowCover
  end

  scope "/", LitcoversWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end
