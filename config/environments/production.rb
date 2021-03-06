Cloudsdale::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # EmberJS
  config.ember.variant = :development

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile"     # apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  config.log_level = :warn
  config.lograge.enabled = true
  config.logger = Logger.new(STDOUT)

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  config.action_controller.asset_host = Figaro.env.asset_url!

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = {
    host: Figaro.env.email_url_host!,
    port: Figaro.env.email_url_port!.to_i
  }

  config.action_mailer.smtp_settings = {
    domain: Figaro.env.email_domain!,
    address: Figaro.env.email_address!,

    port: Figaro.env.email_port!.to_i,

    authentication: :plain,
    enable_starttls_auto: true,

    user_name: Figaro.env.email_user_name!,
    password: Figaro.env.email_password!
  }

end