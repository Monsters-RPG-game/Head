#!/bin/bash

echo "Starting services"

services=("users" "messages" "gateway")
base_dir="./services"

for service in "${services[@]}"; do
  service_path="$base_dir/$service"

  if [[ -d "$service_path" ]]; then
    "$TERMINAL" -e bash -c "cd '$service_path' && npm run start:dev; echo; echo 'Press Enter to close'; read" &
  fi
done

