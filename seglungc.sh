#!/bin/sh
# 
# Lung mask segmentation for Eduardo's Air Trapping dataset on 2014
# for volumetric dataset

INPUTIMAGE=$1
RESDIR=$2
FINALMASK=$3
LUNGNAME=$4

OUTPUTPREFIX=$2/$4

MYDO(){
echo "-------------------------------------------------"
echo $*
echo "-------------------------------------------------"
$*
echo ">>>>>>>>> DONE <<<<<<<<<<<<<<<<"
}


LUNGMASK=${OUTPUTPREFIX}_lungs.nii.gz
AIRWAYMASK=${OUTPUTPREFIX}_airways.nii.gz
SEPARATEMASK=${OUTPUTPREFIX}_separate.nii.gz
SMOOTHMASK=$FINALMASK 

TMPIMAGE=$INPUTIMAGE

UTILITIESDIR=/home/songgang/project/tustison/Utilities/gccrel
#UTILITIESDIR=/home/songgang/project/tustison/Utilities/gccrel_before_May_04_2014

# MYDO ${UTILITIESDIR}/ExtractLungs $TMPIMAGE $LUNGMASK 
# MYDO ${UTILITIESDIR}/SegmentAirways $TMPIMAGE $LUNGMASK $AIRWAYMASK
# MYDO ${UTILITIESDIR}/SeparateLungs $TMPIMAGE $AIRWAYMASK $SEPARATEMASK
# MYDO ${UTILITIESDIR}/SmoothLungs $SEPARATEMASK $SMOOTHMASK 15
c3d $SMOOTHMASK -threshold 2 3 1 0 -o $RESDIR/${LUNGNAME}_lungmask.nii.gz


