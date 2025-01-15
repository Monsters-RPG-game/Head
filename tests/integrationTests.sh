#!/bin/bash

function list_services() {
    ls services
}

function list_tests() {
    # Find only files with the .test.ts extension
    find services/gateway/__tests__/integration/ -type f -name "*.test.ts"
}

if [[ $(list_services) != *gateway* ]]; then
    echo "Error: 'gateway' not found. Make sure to pull all services and prepare their configs."
    exit 1
fi

# Setup each service
echo "Running setup commands for all services..."
for service in $(list_services); do
    cd services/"$service" || exit 1
    echo "Setting up service: $service"
    npm install && make clean && npm run build
    if [[ $? -ne 0 ]]; then
        echo "Setup failed for service: $service. Exiting."
        exit 1
    fi
    cd - >/dev/null || exit 1
done

# Base jest command
base_jest_command="npx cross-env NODE_ENV=test NODE_OPTIONS=--experimental-vm-modules jest"

# Jest config file
jest_config="__tests__/jest.config.integration.ts"

# Function to start the service
function start_service() {
    local service=$1
    if [[ "$service" == "gateway" ]]; then
        echo "Skipping start:testDev for gateway service"
        return
    fi
    cd services/"$service" || exit 1
    echo "Starting service: $service"
    npm run start:testDev &
    service_pid=$!
    cd - >/dev/null || exit 1
}

# Function to stop the service
function stop_service() {
    if [[ -n $service_pid ]]; then
        echo "Stopping service with PID: $service_pid"
        kill $service_pid
        wait $service_pid 2>/dev/null || true
    fi
}

# Iterate through each test file
for test_file in $(list_tests); do
    echo "Running test: $test_file"

    # Start services for integration tests
    for service in $(list_services); do
        start_service "$service"
    done

    # Wait for services to initialize
    echo "Waiting for 3 seconds before starting the test..."
    sleep 3

    # Run test
    cd services/gateway || exit 1
    jest_command="$base_jest_command --config $jest_config $test_file"
    echo $jest_command

    if ! $jest_command; then
        echo "Died: $test_file"
        stop_service
        exit 1
    else
        echo "Test passed: $test_file"
    fi

    cd - >/dev/null || exit 1

    # Stop services after the test
    stop_service
done

