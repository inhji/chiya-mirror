defmodule ChiyaWeb.Router do
  use ChiyaWeb, :router

  import ChiyaWeb.UserAuth
  import ChiyaWeb.GlobalAssigns

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ChiyaWeb.Layouts, :root_app}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :fetch_settings
  end

  pipeline :public do
    plug :put_root_layout, {ChiyaWeb.Layouts, :root_public}
    plug :fetch_identities
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/api", ChiyaWeb do
    pipe_through :api

    get "/admin/notes", ApiController, :notes
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:chiya, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ChiyaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Administrator routes

  scope "/admin", ChiyaWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", AdminController, :home

    resources "/channels", ChannelController
    resources "/notes", NoteController, except: [:show]
    resources "/settings", SettingController, singleton: true
    resources "/identities", IdentityController

    live "/notes/:id", NoteShowLive, :show
  end

  ## Authentication routes

  scope "/", ChiyaWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ChiyaWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/user/register", UserRegistrationLive, :new
      live "/user/log_in", UserLoginLive, :new
      live "/user/reset_password", UserForgotPasswordLive, :new
      live "/user/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/user/log_in", UserSessionController, :create
  end

  scope "/", ChiyaWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ChiyaWeb.UserAuth, :ensure_authenticated}] do
      live "/user", UserProfileLive, :show
      live "/user/settings", UserSettingsLive, :edit
      live "/user/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", ChiyaWeb do
    pipe_through [:browser]

    delete "/user/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ChiyaWeb.UserAuth, :mount_current_user}] do
      live "/user/confirm/:token", UserConfirmationLive, :edit
      live "/user/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  ## Public routes

  scope "/", ChiyaWeb do
    pipe_through [:browser, :public]

    get "/n/:slug", PageController, :note
    get "/:slug", PageController, :channel
    get "/", PageController, :home
  end
end
