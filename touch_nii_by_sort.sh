#!/bin/bash

#touch each nii directory in the sorted order

INPUTDIR=/home/songgang/project/EduardoNewData/data/input/nii
for a in `ls $INPUTDIR | sort -V`; do
	echo touch $INPUTDIR/$a;
	touch $INPUTDIR/$a;
	sleep 1
done