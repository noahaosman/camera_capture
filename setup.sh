#!/bin/bash
#
# Setup script for the camera_capture code
# Must be run as root
#

user=`whoami`
if [[ "$user" != "root" ]]; then
  echo "Must be run as root. Exiting."
  exit 1
fi

basefolder="/home/pi/camera_capture"

# create a folder for the output video files
if [ ! -d $basefolder/output ]; then
  mkdir $basefolder/output
fi
chown -R pi:pi $basefolder/output

# set up the systemd service file
sudo cp $basefolder/camera.service /etc/systemd/system/.
systemctl daemon-reload
systemctl enable camera  # tells the camera service to start on boot

# start the camera script
# systemctl start camera
