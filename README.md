# Monsters - head

## Set of configs used to properly set up services for game 'Monsters'. Project is written in SOA architecture with node.js

## Index

```
1. How to start
2. How to build
3. Communication
```

## 1. How to start:

This project includes docker-compose configs and scripts to initialize services. You can use init.sh file to complete automate services configuration process. You can also use predefined makefile commands to start shorten your work
```shell
chmod +x init.sh
./init.sh
```

If you are planning on using docker-compose, you'll need to add `.env` file. You can edit `example.env` since it
contains all variables required to start project

Otherwise, you can start each service manually. Each service contains `README` file with information, on how to start it

## 2. How to initialize environment

### 2.1 Automated way

#### Init development builds

```shell
make initDev
make prepareDev
```

#### Init production builds

```shell
make initProd
make prepareProd
```

### 2.2 By hand

#### Init submodules
```shell
git submodule init
git submodule update --remote --merge
```

#### Install dependencies for each service

```shell
npm install --prefix ./services/gateway
npm install --prefix ./services/messages
npm install --prefix ./services/users
npm install --prefix ./services/fights
npm install --prefix ./services/maps
```

### 2.3 Important info

Keep in mind that each service requires testConfig.json, prodConfig.json and devConfig.json in `config` folder. You can find required variables in `exampleConfig.json`. Automating this process will be added in the future. You can always use init.sh file to initialize all configs
