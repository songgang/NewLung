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
# instead of naming the final output here, use the input parameter
# SMOOTHMASK=${OUTPUTPREFIX}_smooth.nii.gz
SMOOTHMASK=$FINALMASK 

# THRESHIMAGE=${OUTPUTPREFIX}_threshold.nii.gz
# TMPIMAGE=${OUTPUTPREFIX}_tmp.nii.gz
TMPIMAGE=$INPUTIMAGE

UTILITIESDIR=/home/songgang/project/tustison/Utilities/gccrel
#UTILITIESDIR=/home/songgang/project/tustison/Utilities/gccrel_before_May_04_2014

# MYDO ${UTILITIESDIR}/ThresholdImage 3 $INPUTIMAGE $THRESHIMAGE -10000 -1 0 1
#/mnt/data1/tustison/PICSL/ANTS/bin64/SmoothImage 3 $INPUTIMAGE 1 $TMPIMAGE 1 
# MYDO cp $INPUTIMAGE $TMPIMAGE

# MYDO ${UTILITIESDIR}/ExtractLungs $TMPIMAGE $LUNGMASK $THRESHIMAGE
MYDO ${UTILITIESDIR}/ExtractLungs $TMPIMAGE $LUNGMASK 

MYDO ${UTILITIESDIR}/SegmentAirways $TMPIMAGE $LUNGMASK $AIRWAYMASK

MYDO ${UTILITIESDIR}/SeparateLungs $TMPIMAGE $AIRWAYMASK $SEPARATEMASK

MYDO ${UTILITIESDIR}/SmoothLungs $SEPARATEMASK $SMOOTHMASK 15

# MYDO rm $THRESHIMAGE
# MYDO rm $TMPIMAGE

