#!/bin/bash

# get list of all attached devices
devlist=`v4l2-ctl --list-devices | grep /dev/video`

# change to an array
devarray=($devlist)
numdevs=${#devarray[@]}

# check the format of each attached device
for (( i=0; i<=$numdevs; i++ )); do
  thisdev=${devarray[$i]}
  if [ "$thisdev" != "" ]; then
    # check to see if its an H264 device
    format=`v4l2-ctl --list-formats --device $thisdev | grep H264`
    if [ "$format" != "" ]; then
      # make sure it's the camera
      type=`v4l2-ctl --all --device $thisdev | grep exploreHD`
      if [ "$type" != "" ]; then
        echo "$thisdev"
      fi
    fi
  fi
done
