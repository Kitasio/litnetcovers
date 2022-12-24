# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :litcovers,
  ecto_repos: [Litcovers.Repo]

# Configures gettext
config :litcovers, LitcoversWeb.Gettext, default_locale: "ru", locales: ~w(en ru)

# Configures the endpoint
config :litcovers, LitcoversWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: LitcoversWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Litcovers.PubSub,
  live_view: [signing_salt: "kGE23Ftl"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
# config :litcovers, Litcovers.Mailer, adapter: Swoosh.Adapters.Local
config :litcovers, Litcovers.Mailer,
  adapter: Swoosh.Adapters.Sendinblue,
  api_key: System.get_env("SENDINGBLUE_API_KEY")

# Swoosh API client is needed for adapters other than SMTP.
# config :swoosh, :api_client, false
config :swoosh, :api_client, Swoosh.ApiClient.Hackney

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Tailwind
config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :litcovers, Litcovers.Guardian,
  issuer: "litcovers",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

config :litcovers, Litcovers.ApiAuthPipeline,
  error_handler: Litcovers.ApiAuthErrorHandler,
  module: Litcovers.Guardian

config :litcovers,
  imagekit_url: "https://ik.imagekit.io/soulgenesis",
  bucket: "sapimedia"

config :ex_aws,
  debug_requests: true,
  json_codec: Jason,
  access_key_id: {:system, "SPACES_ACCESS_KEY_ID"},
  secret_access_key: {:system, "SPACES_SECRET_ACCESS_KEY"}

config :ex_aws, :s3,
  scheme: "https://",
  host: "fra1.digitaloceanspaces.com",
  region: "fra1"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
