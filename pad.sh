#!/bin/bash


# pad the following images for better registration
# to avoid boundary effects


# 1. downsampled lung images
# 2. all lung anatomy masks



AP=/home/songgang/project/ANTS/gccrel/bin/



INPUTIMAGE=$1
NVOX=$2
OUTPUTIMAGE=$3

$AP/ImageMath 3 $OUTPUTIMAGE PadImage $INPUTIMAGE $2