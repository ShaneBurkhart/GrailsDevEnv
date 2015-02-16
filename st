#!/usr/bin/env bash

# Change this line to something unique for each project
PROJECT_NAME=budget_ease

# Don't touch these
DATA_CONTAINER_NAME="${PROJECT_NAME}_data_container"
DEV_CONTAINER_NAME="${PROJECT_NAME}_dev_container"

# Flags
FORCE_CLEAN_FLAG=1

# Build docker images
build() {
	if [ -f ./dev/Dockerfile ]; then
		echo "== Build: building ./dev/Dockerfile."
		sudo docker build -t ${DEV_CONTAINER_NAME} ./dev
		echo "== Build: dev container built with image name ${DEV_CONTAINER_NAME}."
	else
		echo "== Error: ./dev/Dockerfile doesn't exist."
		exit 1
	fi
}

# Start dev env.  We start a container to ssh into.
dev() {
	# Build so we know we have latest
	build

	# There might be a better way to do this but we are looking for the container name and checking the
	# exit code of grep. Nothing can come between the following line and the if statement.
	sudo docker ps -a | grep -q "${DATA_CONTAINER_NAME}"
	if [ ${PIPESTATUS[1]} == 0 ]; then
		echo "== Warning: data container ${DATA_CONTAINER_NAME} already exists.  Using existing container."
		echo "== Warning: if you want a new data container, run 'st clean -f'."
	else
		echo "== Dev: creating data container ${DATA_CONTAINER_NAME}."
		sudo docker run -v /home --name=${DATA_CONTAINER_NAME} ubuntu
	fi


	sudo docker ps -a | grep -q "${DEV_CONTAINER_NAME}"
	if [ ${PIPESTATUS[1]} == 0 ]; then
		echo "== Warning: dev container ${DEV_CONTAINER_NAME} already exists.  Stop and remove the existing container."
		echo "== Warning: or run 'st clean'."
	else
		echo "== Dev: creating dev container ${DEV_CONTAINER_NAME}."
		sudo docker run -d --volumes-from=${DATA_CONTAINER_NAME} -p 127.0.0.1:8080:8080 -p 127.0.0.1:22:22 --name=${DEV_CONTAINER_NAME} ${DEV_CONTAINER_NAME}
		echo "== Dev: container ${DEV_CONTAINER_NAME} started."
		echo "== Dev: ssh into container with 'ssh root@localhost'.  The password is 'password'."
		echo "== Dev: port 8080 is forwarded to host so you can run web servers on the dev container."
	fi
}

clean() {
	# Stop containers so we can remove them.
	echo "== Clean: stopping docker containers."
	sudo docker ps | awk '{ if (NR != 1) print $1 }' | xargs --no-run-if-empty sudo docker stop
	echo "== Clean: docker containers stopped."

	if [ $FORCE_CLEAN_FLAG == 0 ]; then
		echo "== Clean: force cleaning."
		echo "== Clean: removing data container ${DATA_CONTAINER_NAME}."
		# Shouldn't need to stop it but we'll do it for safety.
		sudo docker stop ${DATA_CONTAINER_NAME}
		sudo docker rm ${DATA_CONTAINER_NAME}
		echo "== Clean: data container ${DATA_CONTAINER_NAME} removed."
	fi

	# Remove existing containers that aren't data containers
	echo "== Clean: removing docker containers."
	sudo docker ps -a | grep -v data_container | awk '{ if (NR != 1) print $1 }' | xargs --no-run-if-empty sudo docker rm
	echo "== Clean: docker containers removed."
}

status() {
	sudo docker ps -a
}

if [ -z "$1" ]; then
	echo "== Error: no arguments supplied."
	exit 1
fi

if [ $1 == "clean" ]; then
	if [ "$2" ]; then
		FORCE_CLEAN_FLAG=0
	fi
fi

VALID_ARGS=( build dev clean status )

for i in "${VALID_ARGS[@]}"; do
	if [ $1 == $i ]; then
		$1
		exit 1
	fi
done

echo "== Error: Invalid arguement $1."
exit 1

