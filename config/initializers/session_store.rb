# Be sure to restart your server when you modify this file.

# Cloudsdale::Application.config.session_store :mongo_store, key: '_cloudsdale_session', collection: lambda { Mongoid.master.collection('sessions') }

Cloudsdale::Application.config.session_store :redis_store,
  expire_in: 259200,
  :domain => Figaro.env.session_key!,
  :servers => {
    :url => Figaro.env.redis_url!,
    :db => 0,
    :namespace => "cloudsdale:sessions"
  }


# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Cloudsdale::Application.config.session_store :active_record_store
