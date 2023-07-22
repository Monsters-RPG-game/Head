#!make

# Start dockerized server
composeUp:
	npm run --prefix ./services/gateway build \
	&& npm run --prefix ./services/users build \
	&& npm run --prefix ./services/messages build \
	&& sudo -S docker-compose build \
 	&& sudo docker-compose --env-file ./.env up -d

# Initialize projects for production
initProd:
	git submodule init \
	&& git submodule update --remote --merge

# Initialize projects for development
initDev:
	git submodule init \
	&& git submodule update --remote --merge \
	&& git --git-dir=./services/users/.git --work-tree=./services/users checkout dev \
	&& git --git-dir=./services/messages/.git --work-tree=./services/messages checkout dev \
	&& git --git-dir=./services/gateway/.git --work-tree=./services/gateway checkout dev

# Prepare project to run as development server
prepareDev:
	npm install --prefix ./services/gateway \
	&& npm install --prefix ./services/users \
	&& npm install --prefix ./services/messages

# Prepare project to run as production servers
prepareProd:
	npm install --omit=dev --prefix ./services/gateway \
	&& npm install --omit=dev --prefix ./services/users \
	&& npm install --omit=dev --prefix ./services/messages \

# Upgrade all dependencies to latest version from current branch
pullLatest:
	git --git-dir=./services/users/.git --work-tree=./services/users pull \
	&& git --git-dir=./services/messages/.git --work-tree=./services/messages pull \
	&& git --git-dir=./services/gateway/.git --work-tree=./services/gateway pull
