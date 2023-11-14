#!/bin/bash

outpath="/media/usb-drive"

filesink="camera_*_[0-9][0-9][0-9][0-9].mp4"

while :
do

    # find all files that:
    #   1) fit default file sink naming format
    #   2) were last modified at least 10 seconds ago
    filelist=`find "$outpath" -maxdepth 1 -name "$filesink" -mmin +0.167`

    for FILE in $filelist; do 
        
        # remove default indexing from file name
        cam=${FILE/[0-9][0-9][0-9][0-9].mp4}

        # get creation time and clean up into the format we want
        birth=`stat -c '%w' $FILE | cut -f1 -d"." |  tr -d "\-\ \:"`

        # rename file using creation time
        mv $FILE $cam$birth".mp4"
        echo $FILE" --> "$cam$birth".mp4"

    done

    sleep 5

done