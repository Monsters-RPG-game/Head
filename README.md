# Monsters - head

## Set of configs used to properly set up services for game 'Monsters'. Project is written in SOA architecture with node.js

TLDR;
1. [How to start](#1-how-to-start)
2. [How to build](#2-how-to-build)

## 1. How to start:

This project includes docker-compose configs and scripts to initialize services. You can use init.sh file to complete automate services configuration process. You can also use predefined makefile commands to start shorten your work
```bash
chmod +x init.sh
./init.sh
```

> [!IMPORTANT]
> Compose wasn't used by me for a long long time. It might not work

Otherwise, you can start each service manually. Each service contains `README` file with information, on how to start it

This application also includes example.env, which will be used in k8s deployments. docker-compose also include parts of this env, but wasn't tested ( I used compose only once )

## 2. How to initialize environment

### 2.1 Automated way

#### Init development builds

```bash
make initDev
make prepareDev
```

#### Init production builds

```bash
make initProd
make prepareProd
```

### 2.2 By hand

#### Init submodules

```bash
git submodule init
git submodule update --remote --merge
```

#### Install dependencies for each service

```bash
npm install --prefix ./services/gateway
npm install --prefix ./services/messages
npm install --prefix ./services/users
```

> [!IMPORTANT]
> Keep in mind that each service requires testConfig.json, prodConfig.json and devConfig.json in `config` folder. You can find required variables in `exampleConfig.json`. You can always use init.sh file to initialize all configs
