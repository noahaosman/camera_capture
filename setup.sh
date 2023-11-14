#!/bin/bash
#
# Setup script for the camera_capture code
# Must be run as root

user=`whoami`
if [[ "$user" != "root" ]]; then
  echo "Must be run as root. Exiting."
  exit 1
fi

# set the timezone to UTC
timedatectl set-timezone UTC
date

# Enable legacy camera support (if bullseye) 
command -v raspi-config && (
    echo "Running in a Raspiberry."
    if [ $(lsb_release -sc) == "bullseye" ];
    then
        raspi-config nonint get_legacy 1> /dev/null && (
            echo "Enabling legacy camera support."
            raspi-config nonint do_legacy 0
        )
    else
        echo "Not on bullseye - no need to enable legacy camera support"
    fi
)

# install gstreamer requirements
sudo apt-get install libx264-dev libjpeg-dev

# install gstreamer extras 
sudo apt-get install libgstreamer1.0-dev \
libgstreamer-plugins-base1.0-dev \
libgstreamer-plugins-bad1.0-dev \
gstreamer1.0-plugins-base \
gstreamer1.0-plugins-good \
gstreamer1.0-plugins-bad \
gstreamer1.0-plugins-ugly \
gstreamer1.0-tools \
gstreamer1.0-gl \
gstreamer1.0-gtk3 

# location for the camera capture code 
basefolder="/home/pi/camera_capture"

# create a folder for the output video files
if [ ! -d $basefolder/output ]; then
  mkdir $basefolder/output
fi
chown -R pi:pi $basefolder/output

# set up the systemd service files
sudo cp $basefolder/camera.service /etc/systemd/system/.
systemctl daemon-reload
systemctl enable camera  # tells the camera service to start on boot

# start the camera script
systemctl start camera
