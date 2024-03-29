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

    plug SetLocale,
      gettext: LitcoversWeb.Gettext,
      default_locale: "ru"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_authenticated do
    plug Litcovers.ApiAuthPipeline
    plug :fetch_current_user_api
  end

  # Other scopes may use custom stacks.
  scope "/api", LitcoversWeb do
    pipe_through :api

    scope "/v1", V1, as: :v1 do
      post "/sign_in", SessionController, :create
    end
  end

  scope "/api", LitcoversWeb do
    pipe_through [:api, :api_authenticated]

    scope "/v1", V1, as: :v1 do
      resources "/overlays", OverlayController, except: [:new, :edit]
      resources "/requests", RequestController
      post "/prompts", PromptController, :index
      get "/covers/:id", CoverController, :show
    end
  end

  scope "/", LitcoversWeb do
    pipe_through :browser

    get "/", PageController, :dummy
  end

  scope "/:locale", LitcoversWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/docs", PageController, :docs
    live "/wasm", WasmTestLive.Index, :index
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  # if Mix.env() in [:dev, :test] do
  #   import Phoenix.LiveDashboard.Router
  #
  #   scope "/" do
  #     pipe_through :browser
  #
  #     live_dashboard "/dashboard", metrics: LitcoversWeb.Telemetry
  #   end
  # end

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

  scope "/:locale/admin", LitcoversWeb do
    pipe_through [:browser, :require_authenticated_admin]

    resources "/placeholders", PlaceholderController

    live "/", AdminLive.Index
    live "/request/all", RequestsLive.All

    live "/prompts", PromptLive.Index, :index
    live "/prompts/new", PromptLive.Index, :new
    live "/prompts/:id/edit", PromptLive.Index, :edit

    live "/celebs", CelebLive.Index, :index
    live "/celebs/new", CelebLive.Index, :new
    live "/celebs/:id/edit", CelebLive.Index, :edit

    live "/:request_id", AdminLive.Show
  end

  scope "/:locale", LitcoversWeb do
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

  scope "/:locale", LitcoversWeb do
    pipe_through [:browser, :require_authenticated_user, :require_has_litcoins]

    live "/request", RequestsLive.Index
  end

  scope "/:locale", LitcoversWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    live "/profile", ProfileLive.Index
    live "/profile/:request_id", ProfileLive.Show
  end

  scope "/:locale", LitcoversWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end
