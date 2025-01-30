std_msgs/Header header
TrackedOrientedBox[] boxes           # Contains oriented bounding boxes.
sensor_msgs/PointCloud2 point_cloud  # Contains a raw point cloud measurement
                                     # with z=0 in header.frame_id (assuming
                                     # 2D laser scan data).
int32[] point_to_box                 # Contains for each point in the
                                     # point_cloud an index to boxes.
