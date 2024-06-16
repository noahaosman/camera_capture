#!/bin/bash
#
# Script to capture the video feeds from multiple cameras at the same time.
# The output MP4 files will be placed in /media/usb-drive.

# define the output file location
outpath="/media/usb-drive"

# mount the drive
mkdir $outpath
mount -o umask=000 /dev/sda1 $outpath

# Run file re-naming script in the background
#/home/pi/camera_capture/rename_files.sh &

# get the current date for the output filename
now=`date +%Y%m%d%H%M%S`

echo ---"$now"--- >> /home/pi/data/capturevid.log

# make deployment directory
outpath="$outpath"/"$now"
mkdir $outpath

# get list of cameras
camlist=`/home/pi/camera_capture/find_camera.sh`

# change camera list to an array
camarray=($camlist)
numcams=${#camarray[@]}

# create the command to capture the video feeds
# (the commands for all cameras are concatenated together
# into a single one-line command)
command="/usr/bin/gst-launch-1.0 -v "
for (( i=0; i<$numcams; i++ )); do
  thiscam=${camarray[$i]}
  # get the hardware port number the camera is attached to
  bus=`v4l2-ctl --all --device $thiscam | grep usb-`
  busnum="${bus:0-1}"
  # create the command
  command+="\
    v4l2src device=$thiscam \
    ! video/x-h264, width=1920,height=1080,framerate=30/1 \
    ! h264parse \
    ! queue \
    ! splitmuxsink location=$outpath/camera_${busnum}_%04d.mp4 max-size-time=300000000000 muxer-factory=mpegtsmux  \
    "
done
command+=" -e"


# check remaining storage space
avail=`df -k $outpath | tail -1 | awk '{print $4}'`
echo $avail

# if the drive is not full, run the command.
# The command will port both video feeds through one pipeline
# every 5 minutes it will create a new file
if [ $avail -gt 1000000 ]
then
        # run the command
        echo "$command" >> /home/pi/data/capturevid.log
        eval "$command >> /home/pi/data/capturevid.log"
fi
