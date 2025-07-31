#!bash

source ./scripts/utils/logger.sh

function runMigrations() {
  echo_colour "Running migrations"

  services=("users" "messages" "gateway")

  for service in "${services[@]}"; do
    if jq -e '.scripts["migrate"]' "./services/$service/package.json" > /dev/null; then
      echo "Running migrate script..."
      npm --prefix "./services/$service" run migrate:dev >> log.txt
    fi
  done
}

function initialize_dev() {
    echo_colour "Initializing services for development"
    make initDev >> log.txt
    make pullLatest >> log.txt

    make cleanNodeModules >> log.txt
    make cleanCache >> log.txt

    echo_colour "Installing dependencies"
    make prepareDev >> log.txt

    echo_colour "Compiling code"
    make build >> log.txt
}

function initialize_prod() {
    echo_colour "Initializing services for production"
    make initProd >> log.txt
    make pullLatest >> log.txt

    make cleanNodeModules >> log.txt
    make cleanCache >> log.txt

    echo_colour "Installing dependencies"
    make prepareProd >> log.txt

    echo_colour "Compiling code"
    make build >> log.txt
}
