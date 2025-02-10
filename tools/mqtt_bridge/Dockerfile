FROM ghcr.io/ika-rwth-aachen/mqtt_client:ros2

ENV ROS_DISTRO=humble

#RUN "ls"
#RUN apt-get update && \
#    apt-get remove -y ros-${ROS_DISTRO}-* && \
#    apt-get autoremove -y && \
#    rm -rf /var/lib/apt/lists/*

#COPY --from=intermediate /opt/ros /opt/ros

#RUN apt-get update && \
#    apt-get install -y liblttng-ust1 libspdlog1 ros-iron-rmw-cyclonedds-cpp libconsole-bridge1.0 ros-iron-rclcpp ros-humble-rclcpp && \
#    rm -rf /var/lib/apt/lists/*

#RUN mkdir /docker-ros/ws/src
#COPY mqtt_client/mqtt_client /docker-ros/ws/src/
#COPY mqtt_client/mqtt_client_interfaces /docker-ros/ws/src/

#ENV ROS_DISTRO=iron
#WORKDIR /docker-ros/ws
#RUN source /opt/ros/${ROS_DISTRO}/setup.bash && colcon build

COPY params.yaml /docker-ros/ws/install/mqtt_client/share/mqtt_client/config/params.ros2.yaml
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /entrypoint.sh

