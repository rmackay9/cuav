#!/bin/bash

# usage: bayer_to_jpg.sh source-dir dest-dir
# this script continuously scans the source-dir for *.jpg files
# and does the following:
#    - rpi_to_pgm extracts the bayer image into a .ppm file 
#    - pnmtojpeg converts the .ppm file to source-dir/temp/.jpg 
#    - source-dir/temp/.jpg is moved to dest-dir
#    - source-dir/.ppm file is removed
#    - original .jpg file is removed

CONVERTER=~/start_rpi_capture/rpi_to_pgm_fast

# check if converter exists
if [ ! -f $CONVERTER ]; then
    echo "could not find $CONVERTER, exiting"
    exit 1
fi

# check arguments
if [ $# -ne 2 ]; then
    echo "usage: bayer_to_jpg.sh source-dir dest-dir"
    exit 1
fi

SOURCE_DIR=$1
DEST_DIR=$2
TEMP_DIR=$SOURCE_DIR/temp

# create directories
mkdir -p $SOURCE_DIR
mkdir -p $TEMP_DIR
mkdir -p $DEST_DIR

# file pattern matching returns null if no matching files 
shopt -s nullglob

echo "searching for .jpg images in $SOURCE_DIR"

while [ 1 ]; do
    for f in $SOURCE_DIR/*.jpg; do

       # extract bayer from jpg (produces .ppm file)
       echo "Extract bayer from $f"
       time $CONVERTER $f
       echo "done extracter"

       # convert ppm to jpeg
       filename_base=$(basename $f .jpg)
       echo "convert $SOURCE_DIR/$filename_base.ppm to png"
       pnmtojpeg --quality 100 $SOURCE_DIR/$filename_base.ppm > $TEMP_DIR/$filename_base.jpg
   
       # remove ppm
       if [ -f $SOURCE_DIR/$filename_base.ppm ]; then
           rm $SOURCE_DIR/$filename_base.ppm
           echo "removed $filename_base.ppm"
       else
           echo "could not find $SOURCE_DIR/$filename_base.ppm"
       fi

       # move jpg to DEST_DIR
       mv $TEMP_DIR/$filename_base.jpg $DEST_DIR

       # remove original jpg
       if [ -f $SOURCE_DIR/$filename_base.jpg ]; then
           rm $SOURCE_DIR/$filename_base.jpg
           echo "removed $filename_base.jpg"
       else
           echo "could not find $SOURCE_DIR/$filename_base.jpg"
       fi
       
    done
    sleep 1
done

