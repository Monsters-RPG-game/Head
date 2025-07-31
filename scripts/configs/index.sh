#!bash

source ./scripts/utils/logger.sh

declare -A Configs

function which_example_config() {
  echo_colour "Are you using any reverse proxy system ( nginx, apache etc ) ? Or would you like to use localhost"
  echo_colour "1 - localhost"
  echo_colour "2 - reverse proxy"

  read -p "[1/2]: " config_type

  case $config_type in
    "1")
      echo_colour "Using localhost config. Web client will be started on localhost:3003, where backend services will be started on 5003 for gateway API and 5004 for gateway websocket."

      config="./configs/sample.localhost.appConfig.txt"
      ;;
    "2")
      echo_colour "Using reverse proxy config. Web client will be started on front.server.com. Gateway API will be started on api.server.com."
      echo_colour "Please keep in mind that you need to modify your reverse proxy settings. You can find example nginx settings in /samples/nginx.conf."

      config="./configs/sample.reverseProxy.appConfig.txt"
      ;;
    *)
      which_example_config;
      ;;
  esac

  return
}

function init_configs_in_services() {
  echo_colour "Writing config to services"

  services=("users" "messages" "gateway")
  config_files=("devConfig" "prodConfig" "testConfig")

  base_config='{
    "mongo": {
      "url": "",
      "db": "Users",
      "testDb": "Users-test"
    },
    "amqp": {
      "url": "a",
      "myQueue": "usersQueue",
      "gatewayQueue": "gatewayQueue",
      "myService": "users",
      "gatewayService": "gateway"
    },
    "repository": "mongo"
  }'

  gateway_base_config='{
    "mongo": {
      "url": "mongodb://user:password@mongodb:27017",
      "db": "Gateway",
      "testDb": "Gateway-test"
    },
    "amqp": {
      "url": "amqp://user:password@address:port"
    },
    "corsOrigin": ["frontendAddress"],
    "myAddress": "yourAddress",
    "myDomain": "domainUsedByYourApp",
    "authorizationAddress": "addressToAuthorizationsServer",
    "authorizationInnerAddress": "addressToAuthorizationsServer",
    "httpPort": 8080,
    "socketPort": 8081,
    "redisURL": "redis://user:password@address:port",
    "session": {
      "secret": "superSecretKeyPleaseDontLeakIt",
      "secured": false,
      "trustProxy": false
    },
    "metrics": {
      "loki": "loki address"
    },
    "repository": "mongo",
    "tokens": {
      "domain": false
    }
  }'

  for service in "${services[@]}"; do
    if [[ "$service" == "gateway" ]]; then

      for config_file in "${config_files[@]}"; do
        echo "$gateway_base_config" | jq \
          --arg mongoUrl "${Configs[mongoUrl]}" \
          --arg redisUrl "${Configs[redisUrl]}" \
          --arg amqpUrl "${Configs[amqpUrl]}" \
          --arg corsOrigin "${Configs[corsOrigin]}" \
          --arg myAddress "${Configs[myAddress]}" \
          --arg myDomain "${Configs[myDomain]}" \
          --arg authorizationAddress "${Configs[authorizationAddress]}" \
          --arg authorizationInnerAddress "${Configs[authorizationInnerAddress]}" \
          --arg httpPort "${Configs[httpPort]}" \
          --arg socketPort "${Configs[socketPort]}" \
          --arg sessionSecret "${Configs[sessionSecret]}" \
          --arg sessionSecured "${Configs[sessionSecured]}" \
          --arg sessionTrustProxy "${Configs[sessionTrustProxy]}" \
          --arg metricsLoki "${Configs[metricsLoki]}" \
          --arg repository "${Configs[repository]}" \
          --arg tokensDomain "${Configs[tokensDomain]}" '
          .mongo.url = $mongoUrl |
          .amqp.url = $amqpUrl |
          .redisURL = $redisUrl |
          .corsOrigin = [$corsOrigin] |
          .myAddress = $myAddress |
          .myDomain = $myDomain |
          .authorizationAddress = $authorizationAddress |
          .authorizationInnerAddress = $authorizationInnerAddress |
          .httpPort = ($httpPort | tonumber) |
          .socketPort = ($socketPort | tonumber) |
          .session.secret = $sessionSecret |
          .session.secured = ($sessionSecured == "true") |
          .session.trustProxy = ($sessionTrustProxy == "true") |
          .metrics.loki = $metricsLoki |
          .repository = $repository |
          .tokens.domain = ($tokensDomain == "true")
        ' > ./services/"$service"/config/"$config_file".json
      done
    elif [[ "$service" == "users" || "$service" == "messages" ]]; then
      db_name="${service^}"
      my_queue="${service}Queue"

      for config_file in "${config_files[@]}"; do
      echo "$base_config" | jq --arg db "$db_name" \
                              --arg testDb "$db_name-test" \
                              --arg service "$service" \
                              --arg mongoUrl "${Configs[mongoUrl]}" \
                              --arg amqpUrl "${Configs[amqpUrl]}" \
                              --arg myQueue "$my_queue" '
        .mongo.url = $mongoUrl |
        .mongo.db = $db |
        .mongo.testDb = $testDb |
        .amqp.url = $amqpUrl |
        .amqp.myService = $service |
        .amqp.myQueue = $myQueue
        ' > ./services/"$service"/config/"$config_file".json
      done
    fi
  done
}

function basic_config_verify() {
  keys=("mongoUrl" "redisUrl" "amqpUrl" "corsOrigin" "myAddress" "myDomain" "authorizationAddress" "authorizationInnerAddress" "httpPort" "socketPort" "sessionSecret" "sessionSecured" "sessionTrustProxy" "metricsLoki" "repository" "tokensDomain")

 for key in "${keys[@]}"; do
    if [[ -z "${Configs[$key]}" ]]; then
      echo_colour "Something is missing in your config in field:"
      echo "$key"
      echo $Configs
      echo_colour "Please correct your config and retry. You can use ./configs/sample.X.appConfig.txt as an example, or you can read documentation about this."
      exit 1
    fi
  done
}

function verify_config_in_service() {
  echo_colour "Validating configs in services"

  services=("users" "messages" "gateway")

  for service in "${services[@]}"; do
    npm --prefix "./services/$service" run verifyConfig >> log.txt
  done
}

function get_config() {
  read -p "This application uses file in /configs/appConfig.txt as config file. Did you fill it ? Pass 'n' if you wish to use default configs [y/n]: " filled_configs

  if [[ "$filled_configs" == "yes" || "$filled_configs" == "y" ]]; then
    return
  elif [[ "$filled_configs" == "no" ||  "$filled_configs" == "n" ]]; then
    read -p "Do you wish to proceed with example config ? [y/n]: " example_config

    if [[ "$example_config" == "yes" || "$example_config" == "y" ]]; then
      which_example_config;

    elif [[ "$example_config" == "no" ||  "$example_config" == "n" ]]; then
      echo_colour "Please fill out appConfig.txt"
      exit 0
    fi
  else
    get_config
  fi
}

function read_envs() {
  if [[ -n "$RABBIT_USER" && -n "$RABBIT_PASSWORD" ]]; then
    echo_colour "Found envs for rabbit. Overwriting default values"
    Configs["amqpUrl"]="amqp://$RABBIT_USER:$RABBIT_PASSWORD@127.0.0.1:5672"
  fi

  if [[ -n "$MONGO_USER" && -n "$MONGO_PASSWORD" ]]; then
    echo_colour "Found envs for mongo. Overwriting default values"
    Configs["mongoUrl"]="mongodb://${MONGO_USER}:$MONGO_PASWORD@mongo:27017"
  fi

  if [[ -n "$REDIS_PASSWORD" ]]; then
    echo_colour "Found envs for redis. Overwriting default values"
    Configs["redisUrl"]="redis://:$REDIS_PASSWORD@localhost:6379"
  fi
}

function read_config_file() {
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
      value="${value%\"}"
      value="${value#\"}"
      Configs["$key"]="$value"
  done < $config

  read_envs
}

function write_configs() {
    echo_colour "Saving config variables to appConfig.txt"

    for key in "${!Configs[@]}"; do
        echo "$key=${Configs[$key]}" >> appConfig.txt
    done
}

