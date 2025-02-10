
# This Makefile contains useful targets that can be included in downstream projects.

ifeq ($(filter mqtt_bridge.mk, $(notdir $(MAKEFILE_LIST))), mqtt_bridge.mk)

.EXPORT_ALL_VARIABLES:
SHELL:=/bin/bash
MQTT_BRIDGE_PROJECT:=mqtt_bridge

MQTT_BRIDGE_MAKEFILE_PATH:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")
ifeq ($(SUBMODULES_PATH),)
    MQTT_BRIDGE_SUBMODULES_PATH:=${MQTT_BRIDGE_MAKEFILE_PATH}
else
    MQTT_BRIDGE_SUBMODULES_PATH:=$(shell realpath ${SUBMODULES_PATH})
endif
MAKE_GADGETS_PATH:=${MQTT_BRIDGE_SUBMODULES_PATH}/make_gadgets
ifeq ($(wildcard $(MAKE_GADGETS_PATH)/*),)
    $(info INFO: To clone submodules use: 'git submodule update --init --recursive')
    $(info INFO: To specify alternative path for submodules use: SUBMODULES_PATH="<path to submodules>" make build')
    $(info INFO: Default submodule path is: ${MQTT_BRIDGE_MAKEFILE_PATH}')
    $(error "ERROR: ${MAKE_GADGETS_PATH} does not exist. Did you clone the submodules?")
endif

MQTT_BRIDGE_TAG:=$(shell cd "${MAKE_GADGETS_PATH}" && make get_sanitized_branch_name REPO_DIRECTORY="${MQTT_BRIDGE_MAKEFILE_PATH}")
MQTT_BRIDGE_IMAGE:=${MQTT_BRIDGE_PROJECT}:${MQTT_BRIDGE_TAG}
MQTT_BRIDGE_PROJECT_X11_DISPLAY:=${MQTT_BRIDGE_PROJECT}_x11_display
MQTT_BRIDGE_IMAGE_X11_DISPLAY:=${MQTT_BRIDGE_PROJECT_X11_DISPLAY}:${MQTT_BRIDGE_TAG}

SOURCE_DIRECTORY?=${REPO_DIRECTORY}

DOCKER_COMPOSE_FILE?=${MQTT_BRIDGE_MAKEFILE_PATH}/docker-compose.yaml

##ADORE_PATH:=$(shell (find "${MQTT_BRIDGE_SUBMODULES_PATH}" -name adore.mk | xargs realpath | sed "s|/adore.mk||g") 2>/dev/null || true )
#MQTT_BRIDGE_WORKING_DIRECTORY?=${MQTT_BRIDGE_MAKEFILE_PATH}

UID := $(shell id -u)
GID := $(shell id -g)


TEST_SCENARIOS?=adore_scenarios/baseline_test.launch


include ${MAKE_GADGETS_PATH}/make_gadgets.mk
include ${MAKE_GADGETS_PATH}/docker/docker-tools.mk

REPO_DIRECTORY:=${MQTT_BRIDGE_MAKEFILE_PATH}
#CATKIN_WORKSPACE_DIRECTORY:=${REPO_DIRECTORY}/catkin_workspace

MQTT_BRIDGE_SUBMODULES:=make_gadgets 
#include ${MAKE_GADGETS_PATH}/submodule_utils.mk
#$(call include_submodules,${MQTT_BRIDGE_SUBMODULES_PATH}, ${MQTT_BRIDGE_SUBMODULES})

$(shell mkdir -p "${MQTT_BRIDGE_MAKEFILE_PATH}/.ccache")
$(shell mkdir -p "${SOURCE_DIRECTORY}/.log")

.PHONY: mqtt_bridge_up
mqtt_bridge_up: mqtt_bridge_setup mqtt_bridge_start mqtt_bridge_attach mqtt_bridge_teardown 

.PHONY: cli
cli: mqtt_bridge ## Same as 'make mqtt_bridge' for the lazy 

.PHONY: stop_mqtt_bridge
stop_mqtt_bridge: docker_host_context_check mqtt_bridge_teardown ## Stop mqtt_bridge docker context if it is running

.PHONY: stop_mqtt_bridge_setup
stop_mqtt_bridge_setup: docker_host_context_check mqtt_bridge_teardown_setup

.PHONY: mqtt_bridge 
mqtt_bridge: docker_host_context_check build_fast_mqtt_bridge_core ## Start mqtt_bridge context or attach to it if already running
	@if [[ "$$(docker inspect -f '{{.State.Running}}' '${MQTT_BRIDGE_PROJECT}' 2>/dev/null)" == "true"  ]]; then\
        cd "${MQTT_BRIDGE_MAKEFILE_PATH}" && make --file=${MQTT_BRIDGE_MAKEFILE_PATH}/mqtt_bridge.mk mqtt_bridge_attach;\
        exit 0;\
    else\
        cd "${MQTT_BRIDGE_MAKEFILE_PATH}" && make --file=${MQTT_BRIDGE_MAKEFILE_PATH}/mqtt_bridge.mk mqtt_bridge_up;\
        exit 0;\
    fi;

.PHONY: build_fast_mqtt_bridge_core
build_fast_mqtt_bridge_core: # build the mqtt_bridge core context if it does not already exist in the docker repository. If it does exist this is a noop.
	@if [ -n "$$(docker images -q ${MQTT_BRIDGE_PROJECT}:${MQTT_BRIDGE_TAG})" ]; then \
        echo "Docker image: ${MQTT_BRIDGE_PROJECT}:${MQTT_BRIDGE_TAG} already build, skipping build."; \
    else \
        cd "${MQTT_BRIDGE_MAKEFILE_PATH}" && make build_mqtt_bridge_core;\
    fi


.PHONY: build_mqtt_bridge_core
build_mqtt_bridge_core: clean_mqtt_bridge ## Builds the ADORe CLI core docker context/image
	cd "${MQTT_BRIDGE_MAKEFILE_PATH}" && make start_apt_cacher_ng 
	cd "${MQTT_BRIDGE_MAKEFILE_PATH}" && make build 

.PHONY: clean_mqtt_bridge 
clean_mqtt_bridge: ## Clean mqtt_bridge docker context 
	cd "${MQTT_BRIDGE_MAKEFILE_PATH}" && make clean

.PHONY: mqtt_bridge_setup
mqtt_bridge_setup: 
	@echo "Running mqtt_bridge setup... SOURCE_DIRECTORY: ${SOURCE_DIRECTORY}"
	make --file=${MQTT_BRIDGE_MAKEFILE_PATH}/mqtt_bridge.mk build_fast_mqtt_bridge_core
	@mkdir -p ${MQTT_BRIDGE_MAKEFILE_PATH}/.log
	@mkdir -p ${MQTT_BRIDGE_MAKEFILE_PATH}/.ccache
	@touch ${MQTT_BRIDGE_MAKEFILE_PATH}/.bash_history
	@touch ${MQTT_BRIDGE_MAKEFILE_PATH}/.zsh_history
	@touch ${MQTT_BRIDGE_MAKEFILE_PATH}/.zsh_history.new

.PHONY: mqtt_bridge_teardown
mqtt_bridge_teardown:
	@echo "Running mqtt_bridge teardown..."
	@cd ${MQTT_BRIDGE_MAKEFILE_PATH} && docker compose -f ${DOCKER_COMPOSE_FILE} down || true
	@cd ${MQTT_BRIDGE_MAKEFILE_PATH} && docker compose -f ${DOCKER_COMPOSE_FILE} rm -f || true

.PHONY: mqtt_bridge_teardown_setup
mqtt_bridge_teardown_setup:
	@echo "Running mqtt_bridge setup teardown..."
	@cd ${MQTT_BRIDGE_MAKEFILE_PATH} && docker compose -f ${DOCKER_COMPOSE_FILE} stop || true

.PHONY: mqtt_bridge_start
mqtt_bridge_start:
	@echo "Running mqtt_bridge start... SOURCE_DIRECTORY: ${SOURCE_DIRECTORY}"
	cd ${MQTT_BRIDGE_MAKEFILE_PATH} && \
    docker compose  -f ${DOCKER_COMPOSE_FILE} up \
      --force-recreate \
      --renew-anon-volumes \
      --detach;



.PHONY: mqtt_bridge_start_headless
mqtt_bridge_start_headless:
	export DISPLAY_MODE=headless && make --file=${MQTT_BRIDGE_MAKEFILE_PATH}/mqtt_bridge.mk mqtt_bridge_start 

.PHONY: mqtt_bridge_attach
mqtt_bridge_attach:
	@echo "Running mqtt_bridge attach..."
	docker exec -it ${MQTT_BRIDGE_PROJECT} /bin/zsh -c "MQTT_BRIDGE_WORKING_DIRECTORY=${MQTT_BRIDGE_WORKING_DIRECTORY} bash /tmp/mqtt_bridge/tools/mqtt_bridge.sh" || true

.PHONY: branch_mqtt_bridge
branch_mqtt_bridge: ## Returns the current docker safe/sanitized branch for mqtt_bridge 
	@printf "%s\n" ${MQTT_BRIDGE_TAG}

.PHONY: image_mqtt_bridge
image_mqtt_bridge: ## Returns the current docker image name for mqtt_bridge
	@echo "${MQTT_BRIDGE_IMAGE_X11_DISPLAY}"

.PHONY: images_mqtt_bridge
images_mqtt_bridge: ## Returns all docker images for mqtt_bridge
	@echo "${MQTT_BRIDGE_IMAGE}"
	@echo "${MQTT_BRIDGE_IMAGE_X11_DISPLAY}"

endif
