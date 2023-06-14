#!/bin/bash
#
# Script to capture the video feeds from multiple cameras at the same time.
# The output MP4 files will be placed in /home/pi/camera_capture/output.

# define the output file location
outpath="/home/pi/camera_capture/output"

# get the current date for the output filename
now=`date +%Y%m%d%H%M%S`

# get list of cameras
camlist=`/home/pi/camera_capture/find_camera.sh`

# change camera list to an array
camarray=($camlist)
numcams=${#camarray[@]}

# create the command to capture the video feeds
# (the commands for all cameras are concatenated together
# into a single one-line command)
command=""
for (( i=0; i<$numcams; i++ )); do
  thiscam=${camarray[$i]}
  # get the hardware port number the camera is attached to
  bus=`v4l2-ctl --all --device $thiscam | grep usb-`
  busnum="${bus:0-1}"
  # create the command
  command+="/usr/bin/gst-launch-1.0 -v v4l2src device=$thiscam ! video/x-h264, width=1920,height=1080,framerate=30/1 ! h264parse ! queue ! mp4mux ! filesink location=$outpath/camera_${busnum}_$now.mp4 -e"
  if [[ "$i" -lt "$numcams-1" ]]; then
    command+=" | "
  fi
done
echo $command

# run the command
eval "$command"

