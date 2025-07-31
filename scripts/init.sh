#!bash

source ./scripts/utils/logger.sh
source ./scripts/configs/index.sh
source ./scripts/services/index.sh

example_config="./appConfig.txt"
declare -A initialization
declare -A env
config="./configs/appConfig.txt"

# Ask if user has already running services. If no, say that this scripts will run dockerized services on its own. If yes, say that scripts will ask him to provide these data
# Add text file which will be loaded by this script, which user also can edit. Make sure to load it on startup
# Make sure to ask user if he is planning on using reverse proxy. Make sure to init configs for cors for localhost with different ports
# Clean log file at start
# Remove configs files from all services on startup
# Write somewhere that sh files should be chmoded

function get_environment() {
    read -p "Do you want to set up development environment or production environment ? [dev/prod]: " env

    if [[ "$env" == "dev" ]]; then
      initialization=initialize_dev
      env="development"
    elif [[ "$env" == "prod" ]]; then
      initialization=initialize_prod
      env="production"
    else
      get_environment
    fi;
}

function run_environment() {
  read -p "Would you also like to start all external services in docker? Default configs will be used unless overwritten by envs (more in README) [y/n]: " run_services

  if [[ "$run_services" == "yes" || "$run_services" == "y" ]]; then
    declare -A Envs=(
      [RABBIT_USER]="guest"
      [RABBIT_PASSWORD]="guest"
      [MONGO_USER]="admin"
      [MONGO_PASSWORD]="password"
      [REDIS_PASSWORD]="redispass"
    )

    envs=("RABBIT_USER" "RABBIT_PASSWORD" "MONGO_USER" "MONGO_PASSWORD" "REDIS_PASSWORD")

    for env in "${envs[@]}"; do
      if [[ -z "${!env}" ]]; then
        if [[ -n "${Envs[$env]}" ]]; then
          export "$env=${Envs[$env]}"
        fi
      fi
    done

  bash ./scripts/runners/runDev.sh

  elif [[ "$run_services" == "no" || "$run_services" == "n" ]]; then
    return
  else
    run_environment
  fi
}


function greet() {
    echo "" > log.txt

    echo_colour "Hi. This script can be used to initialize all services required for this application. Please keep in mind, that this will remove all config inside each service and fill with provided data from this app."

    read -p "Would you like to start services [y/n]: " start

    if [[ "$start" == "no" || "$start" == "n" ]]; then
      exit 0
    elif [[ "$start" == "yes" || "$start" == "y" ]]; then
      :
    else
      greet
    fi

    get_environment;
    get_config;

    echo_colour "Parsing config";

    read_config_file;
    run_environment;
    basic_config_verify;

    echo_colour "Writing configs";

    init_configs_in_services;

    echo_colour "Running scripts";

    $initialization;

    verify_config_in_service

    runMigrations;

    #
    # These scripts load only data from configs files. We also need to load and pass default passwords for services in case that user wasnt default params
    #

    #TODO Get oidcClients secrets from authorizations service and prefill data from them in gateway to have matching data ( create js scripts for it ? )

    echo_colour "Applications initialized. If you wish to run them in development mode, you can use script from './scripts/runners"
}

greet;
