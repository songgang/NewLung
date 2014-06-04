#!/bin/bash

INPUTDIR=/home/songgang/project/EduardoNewData/data/input/nii
TMPOUTPUTDIR=/home/songgang/project/EduardoNewData/data/input/nii2

for a in `ls $INPUTDIR`; do mv $INPUTDIR/$a/* $TMPOUTPUTDIR; done
echo rm -rf $INPUTDIR
echo mv $TMPOUTPUTDIR $INPUTDIR

# for a in `ls $INPUTDIR`; do
# 	for b in `ls $INPUTDIR/$a`; do
# 		for c in `ls $INPUTDIR/$a/$b`; do
# 			if [ -f $INPUTDIR/$a/$b/$c ]; then
# 				ls -l $INPUTDIR/$a/$b/$c
# 				ls -l $TMPOUTPUTDIR/$b/$c
# 				rm $TMPOUTPUTDIR/$b/$c
# 				mv $INPUTDIR/$a/$b/$c $TMPOUTPUTDIR/$b
# 			fi
# 		done
# 	done
# done
