std_msgs/Header header
float64 center_x          # Box center position x-coordinate.
float64 center_y          # Box center position y-coordinate.
float64 center_z          # Box center position z-coordinate.
float64 angle             # Orientation in rad.
float64 length            # Box dimension 1, in direction of the
                          # orientation.
float64 width             # Box dimension 2, orthogonal to dimension 1.
float64 height            # Box dimension 3, orthogonal to dimension 1 and 2.
float64 velocity_x        # Optional velocity vector x-coordinate; may be NaN.
float64 velocity_y        # Optional velocity vector y-coordinate; may be NaN.
float64 acceleration_x    # Optional acceleration vector x-coordinate; may be NaN.
float64 acceleration_y    # Optional acceleration vector y-coordinate; may be NaN.

uint8 existence_probability # probability of existence 0..100

uint8 sensor_type
bool onboard_sensor
# sensor type values
uint8 UNDEFINED=0
uint8 RADAR=1
uint8 LIDAR=2
uint8 MONO_VIDEO=3
uint8 STEREO_VISION=4
uint8 SPHERICAL_CAMERA=5
uint8 NIGHT_VISION=6
uint8 ULTRASONIC=7
uint8 INDUCTIONLOOP=8
uint8 PMD=9
uint8 FUSED=10
uint8 CAM=11

uint8 classification
uint8 classification_certainty	# confidence of classification 0..100
# classification values
uint8 UNCLASSIFIED=0
uint8 UNKNOWN_SMALL=1
uint8 UNKNOWN_BIG=2
uint8 UNDER_DRIVABLE=3
uint8 OVER_DRIVABLE=4
uint8 PEDESTRIAN=5
uint8 BIKE=6
uint8 BICYCLE=7
uint8 MOPED=8
uint8 MOTORCYCLE=9
uint8 CAR=10
uint8 VAN=11
uint8 BUS=12
uint8 TRUCK=13
uint8 LIGHT_TRUCK=14
uint8 HEAVY_TRUCK=15
uint8 TRAM=16
uint8 TRAILER=17
uint8 SPECIAL_VEHICLE=18
uint8 EGO_VEHICLE=19

# Covariance of the seven dimensional state vector [center_x, center_y, angle,
# length, width, velocity_x, velocity_y]. Some elements may be set to NaN if
# they have not been computed.
#
# Example of a covariance matrix where covariance_center = true,
# covariance_velocity = true and all other covariance flags set to false:
#
#              | 1.0, 0.1, nan, nan, nan, 0.2, 0.2 |
#              | 0.1, 2.0, nan, nan, nan, 0.2, 0.2 |
#              | nan, nan, nan, nan, nan, nan, nan |
# covariance = | nan, nan, nan, nan, nan, nan, nan |
#              | nan, nan, nan, nan, nan, nan, nan |
#              | 0.2, 0.2, nan, nan, nan, 3.0, 2.0 |
#              | 0.2, 0.2, nan, nan, nan, 2.0, 4.0 |
std_msgs/Float64MultiArray covariance

bool covariance_center        # If true, elements of the covariance matrix which
                              # refer to the center_x, center_y are filled with
                              # values. They are set to NaN otherwise.
bool covariance_angle         # If true, the block of the covariance matrix
                              # which refer to the angle are filled with values.
                              # They are set to NaN otherwise.
bool covariance_length_width  # If true, the block of the covariance matrix
                              # which refer to the length and width are filled
                              # with values. They are set to NaN otherwise.
bool covariance_velocity      # If true, the block of the covariance matrix
                              # which refer to the velocity_x and velocity_y are
                              # filled with values. They are set to NaN
                              # otherwise.
