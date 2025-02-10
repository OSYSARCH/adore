cmake_minimum_required(VERSION 3.8)

get_filename_component(CURRENT_DIR_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(TOLOWER ${CURRENT_DIR_NAME} PROJECT)
project(${PROJECT})

include(requirements.cmake)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

execute_process(
    COMMAND sed -i "s/PROJECT/${PROJECT}/g" package.xml
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)


set(MSG_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/msg)
file(GLOB MSG_FILES "${MSG_DIRECTORY}/*.msg")

foreach(MSG_FILE ${MSG_FILES})
    file(RELATIVE_PATH RELATIVE_PATH "${CMAKE_CURRENT_SOURCE_DIR}" "${MSG_FILE}")
    list(APPEND message_files "${RELATIVE_PATH}")
endforeach()

rosidl_generate_interfaces(${PROJECT}
  ${message_files}
  DEPENDENCIES
  geometry_msgs
  shape_msgs
  nav_msgs
  std_msgs
  sensor_msgs
  geometry_msgs
  builtin_interfaces
)


install(
      FILES mapping_rules.yaml
      DESTINATION share/${PROJECT}
)

ament_package()

