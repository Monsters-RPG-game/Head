#!/bin/bash

function echo_colour() {
    COLOUR='\033[1;34m'
    DEFAULT='\033[0m'

    echo -e "${COLOUR}$1${DEFAULT}"
}

function echo_green() {
    COLOUR='\033[0;32m'
    DEFAULT='\033[0m'

    echo -e "${COLOUR}$1${DEFAULT}"
}

echo_colour "Initializing services for development"
make initDev
make pullLatest

echo_colour "Installing dependencies"
make prepareDev

echo_colour "Validating gateway configs"

local="$(dirname "$0")"

usersDevConfig="$local/services/users/config/devConfig.json"
usersTestConfig="$local/services/users/config/testConfig.json"
usersProdConfig="$local/services/users/config/prodConfig.json"

messagesProdConfig="$local/services/messages/config/prodConfig.json"
messagesDevConfig="$local/services/messages/config/devConfig.json"
messagesTestConfig="$local/services/messages/config/testConfig.json"

gatewayProdConfig="$local/services/gateway/config/prodConfig.json"
gatewayDevConfig="$local/services/gateway/config/devConfig.json"
gatewayTestConfig="$local/services/gateway/config/testConfig.json"

amqpURI=""
mongoURI=""
corsOrigin=""
myAddress=""
httpPort=0
socketPort=0
redisURI=""
sessionSecret=""
sessionSecured=false

function create_config_file() {
    local config_file="$1"
    echo_green "$2"

    while [ -z "$amqpURI" ]; do
        read -p "Enter amqpURI [string]: " amqpURI
        if [ -z "$amqpURI" ]; then
            echo "AmqpURI cannot be empty. Provide a correct value."
        fi
    done

    while [ -z "$mongoURI" ]; do
        read -p "Enter mongoURI [string]: " mongoURI
        if [ -z "$mongoURI" ]; then
            echo "MongoURI cannot be empty. Provide a correct value."
        fi
    done

    echo "{\"amqpURI\": \"$amqpURI\", \"mongoURI\": \"$mongoURI\"}" > "$config_file"
    echo_green "Created config file: $config_file"
}

function create_gateway_config_file() {
    local config_file="$1"
    echo_green "$2"

    while [ -z "$amqpURI" ]; do
        read -p "Enter amqpURI [string]: " amqpURI
        if [ -z "$amqpURI" ]; then
            echo "AmqpURI cannot be empty. Provide a correct value."
        fi
    done

    while [ -z "$mongoURI" ]; do
        read -p "Enter mongoURI [string]: " mongoURI
        if [ -z "$mongoURI" ]; then
            echo "MongoURI cannot be empty. Provide a correct value."
        fi
    done

    while [ -z "$corsOrigin" ]; do
        read -p "Enter corsOrigin [string]: " corsOrigin
        if [ -z "$corsOrigin" ]; then
            echo "CorsOrigin cannot be empty. Provide a correct value."
        fi
    done

    while [ -z "$myAddress" ]; do
        read -p "Enter myAddress [string]: " myAddress
        if [ -z "$myAddress" ]; then
            echo "MyAddress cannot be empty. Provide a correct value."
        fi
    done

    while [ -z "$redisURI" ]; do
        read -p "Enter redisURI [string]: " redisURI
        if [ -z "$redisURI" ]; then
            echo "RedisURI cannot be empty. Provide a correct value."
        fi
    done

    while [ -z "$sessionSecret" ]; do
        read -p "Enter sessionSecret [string]: " sessionSecret
        if [ -z "$sessionSecret" ]; then
            echo "SessionSecret cannot be empty. Provide a correct value."
        fi
    done

    while [ -z "$sessionSecured" ]; do
        read -p "Enter sessionSecured [string]: " sessionSecured
        if [ -z "$sessionSecured" ]; then
            echo "SessionSecured cannot be empty. Provide a correct value."
        fi
    done

    while [ "$httpPort" -eq 0 ]; do
        read -p "Enter httpPort [number]" httpPort
        if [ -n "$httpPort" ]; then
            httpPort="$httpPort"
        fi
        if [ "$httpPort" -eq 0 ]; then
            echo "Invalid httpPort. Provide correct value."
        fi
    done

    while [ "$socketPort" -eq 0 ]; do
        read -p "Enter socketPort [number]" socketPort
        if [ -n "$socketPort" ]; then
            socketPort="$socketPort"
        fi
        if [ "$socketPort" -eq 0 ]; then
            echo "Invalid httpPort. Provide correct value."
        fi
    done

cat <<EOF > "$config_file"
{
    "amqpURI": "$amqpURI",
    "mongoURI": "$mongoURI",
    "corsOrigin": "$corsOrigin",
    "myAddress": "$myAddress",
    "httpPort": $httpPort,
    "socketPort": $socketPort,
    "redisURI": "$redisURI",
    "mongoURI": "$mongoURI",
    "session": {
      "secret": "$sessionSecret",
      "secured": $sessionSecured
    }
}
EOF
    echo_green "Created config file: $config_file"
}

# Users configs
if [ ! -f "$usersDevConfig" ]; then
    create_config_file "$usersDevConfig" "Users dev config is missing"
    echo_colour "Created dev config files for users"
fi
if [ ! -f "$usersTestConfig" ]; then
    create_config_file "$usersTestConfig" "Users test config is missing"
    echo_colour "Created test config files for users"
fi
if [ ! -f "$usersProdConfig" ]; then
    create_config_file "$usersProdConfig" "Users prod config is missing"
    echo_colour "Created prod config files for users"
fi

# Messages configs
if [ ! -f "$messagesProdConfig" ]; then
    create_config_file "$messagesProdConfig" "Messages prod config is missing"
    echo_colour "Created prod config files for messages"
fi
if [ ! -f "$messagesDevConfig" ]; then
    create_config_file "$messagesDevConfig" "Messages dev config is missing"
    echo_colour "Created dev config files for messages"
fi
if [ ! -f "$messagesTestConfig" ]; then
    create_config_file "$messagesTestConfig" "Messages test config is missing"
    echo_colour "Created test config files for messages"
fi

# Gateway configs
if [ ! -f "$gatewayProdConfig" ]; then
    create_gateway_config_file "$gatewayProdConfig" "Gateway prod config is missing"
    echo_colour "Created prod config files for gateway"
fi
if [ ! -f "$gatewayDevConfig" ]; then
    create_gateway_config_file "$gatewayDevConfig" "Gateway dev config is missing"
    echo_colour "Created dev config files for gateway"
fi
if [ ! -f "$gatewayTestConfig" ]; then
    create_gateway_config_file "$gatewayTestConfig" "Gateway test config is missing"
    echo_colour "Created test config files for gateway"
fi
