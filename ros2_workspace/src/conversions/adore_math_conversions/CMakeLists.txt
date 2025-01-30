cmake_minimum_required(VERSION 3.8)

get_filename_component(CURRENT_DIR_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(TOLOWER ${CURRENT_DIR_NAME} PROJECT)
project(${PROJECT})

include($ENV{SOURCE_DIRECTORY}/libraries/adore_libraries.cmake)

include_directories(include)

include(requirements.cmake)

add_library(${PROJECT} STATIC src/${PROJECT}.cpp)

target_include_directories(${PROJECT} PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>
)

add_all_target_include_directories(${PROJECT})
add_all_target_link_libraries(${PROJECT})
ament_export_targets(export_${PROJECT} HAS_LIBRARY_TARGET)

#install(TARGETS
#    ${PROJECT}
#  DESTINATION lib/${PROJECT}
#)

install(
    DIRECTORY include/
    DESTINATION include
)

install(
  TARGETS ${PROJECT}
  EXPORT export_${PROJECT}
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION bin
  INCLUDES DESTINATION include
  # DESTINATION lib/${PROJECT_NAME}
)

ament_package()
