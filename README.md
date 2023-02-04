# Monsters - head

## Set of configs used to properly set up services for game 'Monstes'. Project is written in SOA architecture with node.js

## Index

```
1. How to start
2. How to build
3. Communication
```

## 1. How to start:

If you are planning on using docker-compose, you'll need to add `.env` file. You can edit `example.env` since it
contains all variables required to start project

Otherwise, you can start each service manually. Each service contains `README` file with information, on how to start it

## 2. How to build

### 2.1 Automated way

```shell
make prepare
```

### 2.2 By hand

#### Install dependencies for each service

```shell
npm install --prefix ./services/gateway
npm install --prefix ./services/users
```

#### Prepare environment

```shell
chmod +x ./services/users/.husky/pre-commit
chmod +x ./services/gateway/.husky/pre-commit
```

## 3. Communication:

Communication is made using rabbitMQ. Each controller is connecting it and listening to information. Gateway
receives external message, uses some basic validation and passes that message to each worker

