#!/bin/bash

#script to mount thumbdrive

outpath="/media/usb-drive"
sudo mkdir $outpath
sudo mount -o umask=000 /dev/sda1 $outpath

