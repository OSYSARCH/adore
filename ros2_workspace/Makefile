SHELL:=/bin/bash

.DEFAULT_GOAL := help 

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")

.PHONY: help
help:
	@printf "Usage: make \033[36m<target>\033[0m\n%s\n" "$$(awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST) | sort | uniq)"

.PHONY: build
build: ## Build all ROS2 packages
	source /opt/ros/$${ROS_DISTRO}/setup.bash && colcon build --parallel-workers $$(nproc) && source install/local_setup.sh

.PHONY: build_release
build_release: ## Build all ROS2 packages
	source /opt/ros/$${ROS_DISTRO}/setup.bash && colcon build --parallel-workers $$(nproc) --cmake-args -DCMAKE_BUILD_TYPE=Release && source install/local_setup.sh

.PHONY: build_user_libraries
build_user_libraries: 
	cd ../libraries && make build && cd ../ros2_workspace

.PHONY: build_libraries_and_nodes
build_libraries_and_nodes: build_user_libraries build_release


.PHONY: clean_build
clean_build: clean build ## Clean and build all ROS2 packages

.PHONY: clean
clean: ## Clean the ROS2 workspace
	rm -rf build/*
	rm -rf log/*
	rm -rf install/*

.PHONY: test
test:
	colcon test --pytest-args "-m 'not linter'" --event-handlers console_direct+

.PHONY: ccache_stats
ccache_stats: ## Print out CCache Stats 
	ccache -s -v

.PHONY: launch
launch: ## Launch a ROS2 scenario
	@selected_file=$$(find ../adore_scenarios -type f -name "*.py" | fzf --prompt="Select a scenario to launch: ") && \
	if [ -n "$$selected_file" ]; then \
		echo "Launching $$selected_file..."; \
		ros2 launch "$$selected_file"; \
	else \
		echo "No file selected."; \
	fi

