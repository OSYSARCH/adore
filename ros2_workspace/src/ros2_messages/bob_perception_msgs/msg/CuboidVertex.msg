# Message contains location and optionally velocity and covariance of a point.
# When used for a 2D point, 'x' and 'y' should be used, while 'z' should be set to 0.
# Both location and velocity are cartesian!

float64 x
float64 y
float64 z
float64 velocity_x
float64 velocity_y
float64 velocity_z

# Covariance of the state
# The 'has_covariance' entry indicates whether a covariance matrix for location and velocity is included.
# Can be either for a 2D point in image space (without z coordinate) or for a 3D point in world coordinates.
#   Either 3D point (state: [x, y, z, vel_x, vel_y, vel_z]) (world coordinates)
#   or 2D point (state: [x, y, vel_x, vel_y]  (image coordinates).
# This is indicated by the size of the Float64MultiArray containing the covariance information.
bool has_covariance
std_msgs/Float64MultiArray covariance
