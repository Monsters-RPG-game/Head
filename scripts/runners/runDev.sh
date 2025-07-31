#!bash

source ./scripts/utils/logger.sh

echo_colour 'Starting rabbitmq'
docker run -d -p 5672:5672 -p 15672:15672 \
-e RABBITMQ_DEFAULT_USER="${RABBIT_USER}" \
-e RABBITMQ_DEFAULT_PASS="${RABBIT_PASSWORD}" \
--name rabbitMQ \
rabbitmq:3-management

echo_colour 'Starting mongo'
docker run -d -p 27017:27017 \
-e MONGO_INITDB_ROOT_USERNAME="${MONGO_USER}" \
-e MONGO_INITDB_ROOT_PASSWORD="${MONGO_PASSWORD}" \
-v mongodbdata:/data/db \
--name mongo \
mongo

echo_colour 'Starting redis'
docker run -d -p 6379:6379 \
-e REDIS_PASSWORD="${REDIS_PASSWORD}" \
-v redisData:/data/db \
--name redis \
redis \
--requirepass "${REDIS_PASSWORD}"
