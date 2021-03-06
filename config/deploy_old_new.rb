# config/deploy.rb
require "bundler/capistrano"
require 'sidekiq/capistrano'
require 'capistrano_colors'

set :application,   "cloudsdale-web"
set :ruby_version,  "ruby-2.0.0-p247"
set :stage,         "production"

set :socket_path,   "/tmp"

set :keep_releases, 3

set :rake, "#{rake} --trace"

set :scm,             :git
set :scm_verbose,     true

set :repository,      'git@github.com:cloudsdaleapp/cloudsdale.git'
set :remote,          'origin'
set :branch,          'master'

set :migrate_target,  :current
set :ssh_options,     { :forward_agent => true }

set :rails_env,       "production"
set :deploy_to,       "/opt/app/#{application}"

set :user,            "deploy"
set :group,           "deploy"
set :use_sudo,        false

set :bundle_without, [:darwin, :development, :test]

# Sidekiq
set :sidekiq_cmd, "bundle exec sidekiq"
set :sidekiqctl_cmd, "bundle exec sidekiqctl"
set :sidekiq_timeout, 100
set :sidekiq_role, :app
set :sidekiq_pid, "#{shared_path}/pids/sidekiq.pid"
set :sidekiq_processes, 1
set :sidekiq_concurrency, 8

# Puma
set :puma_sock,     "unix://#{socket_path}/cloudsdale-puma.sock"
set :puma_control,  "unix://#{socket_path}/cloudsdale-puma-ctl.sock"
set :puma_state,    "#{socket_path}/cloudsdale-puma.state"
set :puma_log,      "#{shared_path}/log/puma-#{stage}.log"

# Unicorn
set :unicorn_pid , "#{shared_path}/pids/unicorn.pid"
set :unicorn_role, :web

role :db,   "www.cloudsdale.org"
role :web,  "www.cloudsdale.org"
role :app,  "www.cloudsdale.org", :primary => true

after 'deploy', 'deploy:permissions:correct'
after 'deploy', 'deploy:db:create_indexes', 'deploy:db:migrate'
after 'deploy:create_symlink', 'deploy:assets:upload'
after 'deploy:create_symlink', 'sidekiq:link_assets'

# Default Environment
default_environment["RAILS_ENV"]    = rails_env
default_environment["PATH"]         = "/usr/local/rvm/gems/#{ruby_version}/bin:/usr/local/rvm/gems/#{ruby_version}@global/bin:/usr/local/rvm/rubies/#{ruby_version}/bin:/usr/local/rvm/gems/#{ruby_version}@#{application}/bin:/usr/local/rvm/gems/#{ruby_version}@global/bin:/usr/local/rvm/rubies/#{ruby_version}/bin:/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
default_environment["GEM_HOME"]     = "/usr/local/rvm/gems/#{ruby_version}"
default_environment["GEM_PATH"]     = "/usr/local/rvm/gems/#{ruby_version}@#{application}:/usr/local/rvm/gems/#{ruby_version}@global"
default_environment["RUBY_VERSION"] = "#{ruby_version}"

namespace :deploy do

  desc 'Correct permission on all application files to the deploy user.'
  namespace :permissions do
    task :correct, :roles => :app, :except => { :no_release => true } do
      run "sudo chown -R #{user}:#{group} /opt/app/#{application}"
      run "sudo chmod -R go+rw #{deploy_to}/current/tmp/ember-rails"
    end
  end

  namespace :assets do

    desc "Deploy assets to Rackspace CloudFiles."
    task :upload, roles: [:app], except: { no_release: true }, only: { primary: true } do
      run_rake_task "assets:upload"
    end

    desc "Sync assets with Fog Bucket"
    task :sync, roles: [:app], except: { no_release: true }, only: { primary: true } do
      run_rake_task "assets:sync"
    end

  end

  desc "Restart the application"
  task :restart, :roles => unicorn_role, :except => { :no_release => true } do
    # PUMA
    # run "cd #{current_path} && RAILS_ENV=#{stage} && bundle exec pumactl -S #{puma_state} restart"
    # UNICORN
    run "kill -s USR2 `cat #{unicorn_pid}`"
  end

  desc "Start the application"
  task :start, :roles => unicorn_role, :except => { :no_release => true } do
    # PUMA
    # run "cd #{current_path} && RAILS_ENV=#{stage} && bundle exec puma -b '#{puma_sock}' -e #{stage} -t16:16 --control '#{puma_control}' -S #{puma_state} >> #{puma_log} 2>&1 &", :pty => false
    # UNICORN
    run "cd #{current_path} ; bundle exec unicorn_rails -c #{current_path}/config/unicorn.rb -E #{rails_env} -D"
  end

  desc "Stop the application"
  task :stop, :roles => unicorn_role, :except => { :no_release => true } do
    # PUMA
    # run "cd #{current_path} && RAILS_ENV=#{stage} && bundle exec pumactl -S #{puma_state} stop"
    # UNICORN
    run "kill -s QUIT `cat #{unicorn_pid}`"
  end

  desc "Status of the application"
  task :status, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{stage} && bundle exec pumactl -S #{puma_state} stats"
  end

  namespace :db do
    desc "Migrating database"
    task :migrate do
      run "cd #{current_path} && rake db:migrate"
    end

    task :remove_indexes do
      run "cd #{current_path} && rake db:mongoid:remove_indexes"
    end

    task :create_indexes do
      run "cd #{current_path} && rake db:mongoid:create_indexes"
    end
  end

end

namespace :sidekiq do

  desc "Moves the sidekiq assets in to the project folder so they can be served."
  task :link_assets, roles: :web do
    bundle_path = capture "cd #{current_path}; bundle show sidekiq"
    bundle_path = "#{bundle_path.strip}/web/assets"
    run "mkdir -p #{current_path}/public/admin"
    run "ln -fs #{bundle_path} #{current_path}/public/admin"
    run "mv #{current_path}/public/admin/assets #{current_path}/public/admin/workers"
  end

end

def run_rake_task(rake_task)
  run "cd #{deploy_to}/current && /usr/bin/env RAILS_ENV=#{rails_env} SHARED_PATH=#{shared_path} rake #{rake_task}"
end