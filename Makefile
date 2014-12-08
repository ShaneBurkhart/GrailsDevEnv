# Change this line to something unique for each project
PROJECT_NAME=go_DI_framework

DATA_CONTAINER_NAME=$(PROJECT_NAME)_data_container

all: build run

build:
	docker build -t dev ./dev

data_container:
	docker build -t data ./data
	docker run --name=$(DATA_CONTAINER_NAME) data

run:
	docker run -d --volumes-from=$(DATA_CONTAINER_NAME) -p 127.0.0.1:22:22 --name=dev dev

clean:
	docker ps | awk '{ if (NR != 1) print $$1 }' | xargs --no-run-if-empty docker stop
	docker ps -a | grep -v data_container | awk '{ if (NR != 1) print $$1 }' | xargs --no-run-if-empty docker rm

status:
	docker ps -a
