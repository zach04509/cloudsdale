#!/bin/sh

set -e

APP_NAME=${APP_NAME:-cloudsdale-web}
APP_HOME=${APP_HOME:-.}
CONFIG_FILE=$APP_HOME/config/application.yml

echo " ---> setting up configuration"
if [ -f $CONFIG_FILE ]; then
  echo " ---> $CONFIG_FILE already exists"
else
  cp $CONFIG_FILE.example $CONFIG_FILE
  echo " ---> $CONFIG_FILE copied from example"
fi

echo " ---> installing dependencies"
if [ -x "$(which bundle)" ]; then
  echo " ---> $(which bundle) already exists"
else
  gem install --quiet bundle
  echo " ---> installed bundler at $(which bundle)"
fi
echo " ---> bundling ruby gems"
bundle install --quiet

if [ $RAILS_ENV = "test" ]; then
  echo " ---> running tests"
else
  if [ $RAILS_ENV = "development" ]; then
    echo " ---> preparing database"
    bundle exec rake db:create db:migrate db:create_indexes
  fi
  echo " ---> copying $APP_HOME/public to /var/www/cloudsdale-web"
  mkdir -p /var/www/$APP_NAME
  cp -rf $APP_HOME/public/ /var/www/$APP_NAME/
  echo " ---> running application"
fi

cd $APP_HOME
exec "$@"