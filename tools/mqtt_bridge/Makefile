SHELL:=/bin/bash

.DEFAULT_GOAL := all

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=
SUBMODULES_PATH?=$(shell realpath "../")

MQTT_BROKER_HOST := $(shell grep '^[[:space:]]*host:' params.yaml | sed 's/[[:space:]]*host:[[:space:]]*//')


include mqtt_bridge.mk

USER := $(shell whoami)
UID := $(shell id -u)
GID := $(shell id -g)

.PHONY: set_env 
set_env:
	$(eval PROJECT := ${MQTT_BRIDGE_PROJECT}) 
	$(eval TAG := ${MQTT_BRIDGE_TAG})

.PHONY: start
start: set_env down ## Start mqtt bridge docker context OFFLINE 
	@echo "Starting mqtt bridge..."
	docker run --rm --network host --detach --name mosquitto eclipse-mosquitto 
	docker run  --ipc=host --pid=host --detach --privileged  --rm --network host --name ${PROJECT} ${PROJECT}:${TAG}
	@echo "mqtt bridge started"

.PHONY: stop
stop: ## Start mqtt bridge docker context OFFLINE 
	@echo "Stopping mqtt bridge..."
	make down
	@echo "mqtt bridge stopped"

.PHONY: build_fast_mqtt_bridge
build_fast_mqtt_bridge: set_env# Build mqtt_bridge if it does not already exist in the docker repository. If it does exist this is a noop.
	@if [ -n "$$(docker images -q ${PROJECT}:${TAG})" ]; then \
        echo "Docker image: ${PROJECT}:${TAG} already build, skipping build."; \
    else \
        make build;\
    fi


.PHONY: build
build: set_env
	docker build --network host \
                 --tag ${PROJECT}:${TAG} \
                 --build-arg PROJECT=${PROJECT} .

.PHONY: up
up: set_env build_fast_mqtt_bridge down ## Start mqtt bridge docker context 
	docker run --rm --network host --detach --name mosquitto eclipse-mosquitto 
	docker run  --ipc=host --pid=host --detach  --privileged  --rm --network host --name ${PROJECT} ${PROJECT}:${TAG}

.PHONY: down
down: set_env ## Stop mqtt bridge docker context 
	docker stop mosquitto 1>/dev/null 2>&1 || true
	docker stop ${PROJECT} 1>/dev/null 2>&1 || true
	docker stop --force $$(docker ps -q --filter ancestor=eclipse-mosquitto) > /dev/null 2>&1 || true



.PHONY: clean 
clean: set_env ## Clean/delete mqtt_bridge docker images 
	docker rm $$(docker ps -a -q --filter "ancestor=${PROJECT}:${TAG}") --force 2> /dev/null || true
	docker rmi $$(docker images -q ${PROJECT}:${TAG}) --force 2> /dev/null || true
	docker rmi $$(docker images --filter "dangling=true" -q) --force > /dev/null 2>&1 || true

.PHONY: debug
debug: set_env
	docker exec -it ${PROJECT} /bin/bash

.PHONY: mqtt_echo
mqtt_echo: ## echo all mqtt messages
	echo ${MQTT_BROKER_HOST}
	docker run --rm --network host eclipse-mosquitto mosquitto_sub -h ${MQTT_BROKER_HOST} -t "#" -v 

.PHONY: mqtt_publish
mqtt_publish: ## Publish demo mqtt message
#	while true; do mosquitto_pub -h localhost -t pingpong/ros -m "Hello MQTT"; sleep 1s; done
	docker run --rm --network host eclipse-mosquitto mosquitto_pub -h ${MQTT_BROKER_HOST} -t "pingpong/primitive" --repeat 10 --repeat-delay 1 -m 69

.PHONY: mqtt_publish_sample_data
mqtt_publish_sample_data:
	while true; do docker run -v "${ROOT_DIR}/sample_data.json:/sample_data.json" --rm --network host eclipse-mosquitto mosquitto_pub -h ${MQTT_BROKER_HOST} -t "/MAV/control/waypoint_suggestion" -f /sample_data.json; sleep 1; done

.PHONY: publish_ack
publish_ack:
	docker run --rm --network host eclipse-mosquitto mosquitto_pub -h localhost -t "/MAV/1/control/RO/path_acknowledgement" -m "true" -q 1; \

.PHONY: publish_waypoint_suggestion
publish_waypoint_suggestion:
	while true; do docker run -v "${ROOT_DIR}/waypoint_suggestion.json:/sample_data.json" --rm --network host eclipse-mosquitto mosquitto_pub -h ${MQTT_BROKER_HOST} -t "MAV/1/control/RO/waypoint_suggestion" -f /sample_data.json; sleep 1; done
.PHONY: publish_path_acknowledgement
publish_path_acknowledgement:
	while true; do docker run -v "${ROOT_DIR}/path_acknowledgement.json:/sample_data.json" --rm --network host eclipse-mosquitto mosquitto_pub -h ${MQTT_BROKER_HOST} -t "MAV/1/control/RO/path_acknowledgement" -f /sample_data.json; sleep 1; done

.PHONY: publish_ack_prime
publish_ack_prime:
.PHONY: publish_ack_prime
publish_ack_prime:
	docker run --rm --network host eclipse-mosquitto mosquitto_pub -h ${MQTT_BROKER_HOST} -t "/MAV/control/trajectory_acknowledgement" -m "false" -q 1; \

.PHONY: publish_showcase
publish_showcase:
	docker run -v "${ROOT_DIR}/showcase.json:/showcase.json" --rm --network host eclipse-mosquitto mosquitto_pub -h localhost -t "/MAV/state/subsystem_state" -f /showcase.json

.PHONY: mqtt_publish_kill
mqtt_publish_kill:
	kill -9 $$(ps -ef | grep mqtt_bridge | grep eclipse-mosquitto | awk '{print $2}')

