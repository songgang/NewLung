#!/bin/bash

INPUTDIR=/home/songgang/project/EduardoNewData/data/input/nii
TMPOUTPUTDIR=/home/songgang/project/EduardoNewData/data/input/nii2

for a in `ls $INPUTDIR`; do mv $INPUTDIR/$a/* $TMPOUTPUTDIR; done