#!/bin/bash

# resample all lung images to the resolution of 1x1x1mm


INPUT=$1
OUTPUT=$2

c3d $1 -resample-mm 1.5x1.5x1.5mm -o $2