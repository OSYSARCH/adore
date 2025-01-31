/********************************************************************************
 * Copyright (C) 2024-2025 German Aerospace Center (DLR).
 * Eclipse ADORe, Automated Driving Open Research https://eclipse.org/adore
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * Contributors:
 *    Marko Mizdrak
 ********************************************************************************/
#include "adore_dynamics_conversions.hpp"

namespace adore
{
namespace dynamics
{
namespace conversions
{

void
update_state_with_odometry( VehicleStateDynamic& state, const nav_msgs::msg::Odometry& odom )
{
  state.x = odom.pose.pose.position.x;
  state.y = odom.pose.pose.position.y;
  state.z = odom.pose.pose.position.z;

  state.yaw_angle = adore::math::get_yaw( odom.pose.pose.orientation );
  state.vx        = odom.twist.twist.linear.x;
  state.vy        = odom.twist.twist.linear.y;
  state.yaw_rate  = odom.twist.twist.angular.z;

  state.time = static_cast<double>( odom.header.stamp.sec ) + 1e-9 * static_cast<double>( odom.header.stamp.nanosec );
}

adore_ros2_msgs::msg::VehicleCommand
to_ros_msg( const VehicleCommand& command )
{
  adore_ros2_msgs::msg::VehicleCommand msg;
  msg.steering_angle = command.steering_angle;
  msg.acceleration   = command.acceleration;
  return msg;
}

VehicleCommand
to_cpp_type( const adore_ros2_msgs::msg::VehicleCommand& msg )
{
  VehicleCommand command;
  command.steering_angle = msg.steering_angle;
  command.acceleration   = msg.acceleration;
  return command;
}

adore_ros2_msgs::msg::VehicleStateDynamic
to_ros_msg( const VehicleStateDynamic& state )
{
  adore_ros2_msgs::msg::VehicleStateDynamic msg;
  msg.time           = state.time;
  msg.x              = state.x;
  msg.y              = state.y;
  msg.z              = state.z;
  msg.vx             = state.vx;
  msg.vy             = state.vy;
  msg.yaw_angle      = state.yaw_angle;
  msg.yaw_rate       = state.yaw_rate;
  msg.ax             = state.ax;
  msg.ay             = state.ay;
  msg.steering_angle = state.steering_angle;
  msg.steering_rate  = state.steering_rate;
  return msg;
}

VehicleStateDynamic
to_cpp_type( const adore_ros2_msgs::msg::VehicleStateDynamic& msg )
{
  VehicleStateDynamic state;
  state.time           = msg.time;
  state.x              = msg.x;
  state.y              = msg.y;
  state.z              = msg.z;
  state.vx             = msg.vx;
  state.vy             = msg.vy;
  state.yaw_angle      = msg.yaw_angle;
  state.yaw_rate       = msg.yaw_rate;
  state.ax             = msg.ax;
  state.ay             = msg.ay;
  state.steering_angle = msg.steering_angle;
  state.steering_rate  = msg.steering_rate;
  return state;
}

adore_ros2_msgs::msg::GearState
to_ros_msg( const GearState& gear )
{
  adore_ros2_msgs::msg::GearState msg;
  msg.gear_state = static_cast<uint8_t>( gear );
  return msg;
}

GearState
to_cpp_type( const adore_ros2_msgs::msg::GearState& msg )
{
  return static_cast<GearState>( msg.gear_state );
}

adore_ros2_msgs::msg::VehicleInfo
to_ros_msg( const VehicleInfo& info )
{
  adore_ros2_msgs::msg::VehicleInfo msg;
  msg.gear_state                    = to_ros_msg( info.gear_state );
  msg.wheel_speed                   = info.wheel_speed;
  msg.left_indicator_on             = info.left_indicator_on;
  msg.right_indicator_on            = info.right_indicator_on;
  msg.automatic_steering_on         = info.automatic_steering_on;
  msg.automatic_acceleration_on     = info.automatic_acceleration_on;
  msg.automatic_acceleration_active = info.automatic_acceleration_active;
  msg.clearance                     = info.clearance;
  return msg;
}

VehicleInfo
to_cpp_type( const adore_ros2_msgs::msg::VehicleInfo& msg )
{
  VehicleInfo info;
  info.gear_state                    = to_cpp_type( msg.gear_state );
  info.wheel_speed                   = msg.wheel_speed;
  info.left_indicator_on             = msg.left_indicator_on;
  info.right_indicator_on            = msg.right_indicator_on;
  info.automatic_steering_on         = msg.automatic_steering_on;
  info.automatic_acceleration_on     = msg.automatic_acceleration_on;
  info.automatic_acceleration_active = msg.automatic_acceleration_active;
  info.clearance                     = msg.clearance;
  return info;
}

// Existing functions converting VehicleStateDynamic to other ROS messages
nav_msgs::msg::Odometry
dynamic_state_to_odometry_msg( const VehicleStateDynamic& vehicle_state, rclcpp::Clock::SharedPtr clock )
{
  nav_msgs::msg::Odometry odometry_msg;

  // Set header timestamp using the provided clock
  odometry_msg.header.stamp = clock->now();

  // Set position
  odometry_msg.pose.pose.position.x = vehicle_state.x;
  odometry_msg.pose.pose.position.y = vehicle_state.y;
  odometry_msg.pose.pose.position.z = vehicle_state.z; // Assuming 3D

  // Set orientation based on yaw_angle (yaw angle)
  tf2::Quaternion car_orientation_quaternion;
  car_orientation_quaternion.setRPY( 0, 0, vehicle_state.yaw_angle );

  odometry_msg.pose.pose.orientation.x = car_orientation_quaternion.x();
  odometry_msg.pose.pose.orientation.y = car_orientation_quaternion.y();
  odometry_msg.pose.pose.orientation.z = car_orientation_quaternion.z();
  odometry_msg.pose.pose.orientation.w = car_orientation_quaternion.w();

  // Set linear velocity
  odometry_msg.twist.twist.linear.x = vehicle_state.vx;
  odometry_msg.twist.twist.linear.y = vehicle_state.vy;
  odometry_msg.twist.twist.linear.z = vehicle_state.ay; // Assuming 'ay' as z velocity

  // Set angular velocity (yaw rate)
  odometry_msg.twist.twist.angular.x = 0;
  odometry_msg.twist.twist.angular.y = 0;
  odometry_msg.twist.twist.angular.z = vehicle_state.yaw_rate;

  return odometry_msg;
}

geometry_msgs::msg::TransformStamped
vehicle_state_to_transform( const VehicleStateDynamic& vehicle_state, const rclcpp::Time& timestamp )
{
  geometry_msgs::msg::TransformStamped vehicle_frame;

  vehicle_frame.header.stamp    = timestamp;
  vehicle_frame.header.frame_id = "world";
  vehicle_frame.child_frame_id  = "ego_vehicle";

  vehicle_frame.transform.translation.x = vehicle_state.x;
  vehicle_frame.transform.translation.y = vehicle_state.y;
  vehicle_frame.transform.translation.z = vehicle_state.z; // Assuming 3D

  tf2::Quaternion q;
  q.setRPY( 0, 0, vehicle_state.yaw_angle );

  vehicle_frame.transform.rotation.x = q.x();
  vehicle_frame.transform.rotation.y = q.y();
  vehicle_frame.transform.rotation.z = q.z();
  vehicle_frame.transform.rotation.w = q.w();

  return vehicle_frame;
}

adore_ros2_msgs::msg::Trajectory
to_ros_msg( const Trajectory& trajectory )
{
  adore_ros2_msgs::msg::Trajectory msg;
  for( const auto& state : trajectory.states )
  {
    msg.states.push_back( to_ros_msg( state ) );
  }
  msg.label = trajectory.label;
  return msg;
}

Trajectory
to_cpp_type( const adore_ros2_msgs::msg::Trajectory& msg )
{
  Trajectory trajectory;
  for( const auto& ros_state : msg.states )
  {
    trajectory.states.push_back( to_cpp_type( ros_state ) );
  }
  trajectory.label = msg.label;
  return trajectory;
}

adore_ros2_msgs::msg::TrajectoryTranspose
transpose( const adore_ros2_msgs::msg::Trajectory& msg )
{
  adore_ros2_msgs::msg::TrajectoryTranspose transpose;

  for( const auto& ros_state : msg.states )
  {
    transpose.x.push_back( ros_state.x );
    transpose.y.push_back( ros_state.y );
    transpose.z.push_back( ros_state.z );
    transpose.vx.push_back( ros_state.vx );
    transpose.vy.push_back( ros_state.vy );
    transpose.ax.push_back( ros_state.ax );
    transpose.ay.push_back( ros_state.ay );
    transpose.yaw_angle.push_back( ros_state.yaw_angle );
    transpose.yaw_rate.push_back( ros_state.yaw_rate );
    transpose.steering_angle.push_back( ros_state.steering_angle );
    transpose.steering_rate.push_back( ros_state.steering_rate );
    transpose.time.push_back( ros_state.time );
  }
  return transpose;
}

adore_ros2_msgs::msg::TrafficParticipant
to_ros_msg( const TrafficParticipant& participant )
{
  adore_ros2_msgs::msg::TrafficParticipant msg;

  // Convert state
  msg.motion_state = to_ros_msg( participant.state );

  // Convert bounding box
  msg.shape.type       = shape_msgs::msg::SolidPrimitive::BOX;
  msg.shape.dimensions = { participant.bounding_box.length, participant.bounding_box.width, participant.bounding_box.height };

  // Convert classification
  msg.classification.type_id = static_cast<uint8_t>( participant.classification );

  // Convert id
  msg.tracking_id = participant.id;

  // Optional goal point
  if( participant.goal_point )
  {
    msg.goal_point.x = participant.goal_point->x;
    msg.goal_point.y = participant.goal_point->y;
  }

  // Optional trajectory
  if( participant.trajectory )
  {
    msg.predicted_trajectory = to_ros_msg( *participant.trajectory );
  }

  // Optional route
  if( participant.route )
  {
    msg.route = map::conversions::to_ros_msg( *participant.route );
  }

  return msg;
}

TrafficParticipant
to_cpp_type( const adore_ros2_msgs::msg::TrafficParticipant& msg )
{
  // Convert state
  VehicleStateDynamic state = to_cpp_type( msg.motion_state );

  // Convert bounding box
  math::Box3d bounding_box( msg.shape.dimensions[0], // length
                            msg.shape.dimensions[1], // width
                            msg.shape.dimensions[2]  // height
  );

  // Convert classification
  TrafficParticipantClassification classification = static_cast<TrafficParticipantClassification>( msg.classification.type_id );

  // Construct the participant
  TrafficParticipant participant( state, msg.tracking_id, classification, bounding_box.length, bounding_box.width, bounding_box.height );

  // Optional goal point
  if( msg.goal_point.x != 0.0 || msg.goal_point.y != 0.0 )
  {
    adore::math::Point2d goal_point;
    goal_point.x           = msg.goal_point.x;
    goal_point.y           = msg.goal_point.y;
    participant.goal_point = goal_point;
  }

  // Optional trajectory
  if( !msg.predicted_trajectory.states.empty() )
  {
    participant.trajectory = to_cpp_type( msg.predicted_trajectory );
  }

  // Optional route
  if( !msg.route.center_points.empty() )
  {
    participant.route = adore::map::conversions::to_cpp_type( msg.route );
  }

  return participant;
}

adore_ros2_msgs::msg::TrafficParticipantSet
to_ros_msg( const TrafficParticipantSet& participant_set )
{
  adore_ros2_msgs::msg::TrafficParticipantSet msg;

  for( const auto& [id, participant] : participant_set.participants )
  {
    adore_ros2_msgs::msg::TrafficParticipantDetection detection_msg;

    // Convert participant
    detection_msg.participant_data = to_ros_msg( participant );

    // Populate detection information (default example)
    detection_msg.detection_by_sensor = adore_ros2_msgs::msg::TrafficParticipantDetection::UNDEFINED;

    msg.data.push_back( detection_msg );
  }
  if( participant_set.validity_area )
  {
    msg.validity_area = math::conversions::to_ros_msg( participant_set.validity_area.value() );
  }

  return msg;
}

TrafficParticipantSet
to_cpp_type( const adore_ros2_msgs::msg::TrafficParticipantSet& msg )
{
  TrafficParticipantSet participant_set;

  for( const auto& detection : msg.data )
  {
    const auto&        participant_msg = detection.participant_data;
    TrafficParticipant participant     = to_cpp_type( participant_msg );

    participant_set.participants[participant.id] = participant;
  }
  if( msg.validity_area.points.size() > 5 )
  {
    participant_set.validity_area = math::conversions::to_cpp_type( msg.validity_area );
  }

  return participant_set;
}
} // namespace conversions
} // namespace dynamics
} // namespace adore
