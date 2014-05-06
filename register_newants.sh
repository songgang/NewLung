#!/bin/bash

##
# This script performs the following operations:
#   1. registers (using ANTS) $1-fixed to $2-moving
# 
##

if [[ $NSLOTS -gt 1 ]]; then
  ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$NSLOTS
else
  ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
fi

tic(){
START=$(date +%s)
}

toc(){
# START=$(date +%s)
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"
}

function register_new_ants()
{
  dim=3 # image dimensionality
  AP=/home/songgang/project/ANTS/gccrel/bin/  # path to ANTs binaries

  casename=$1
  f=$2; fmask=$3; m=$4; mmask=$5; # fixed and moving image file names 
  OUTPUTDIR=$6;
  
  if [[ ! -s $f ]] ; then echo no fixed $f ; exit; fi
  if [[ ! -s $m ]] ; then echo no moving $m ;exit; fi
  
  nm1=` basename $f | cut -d '.' -f 1 `
  nm2=` basename $m | cut -d '.' -f 1 `

  reg=${AP}/antsRegistration
  
  
  nm=$OUTPUTDIR/${nm1}_fixed_${nm2}_moving_${casename}   # construct output prefix

  echo register fix $f 
  echo register mov $m 
  echo outname is $nm 


  its=10000x10000x10000x10000x0
  percentage=0.1

  $reg -d $dim -r [ $f, $m ,1]  \
    -m mattes[  $fmask, $mmask, 1 , 32, regular, $percentage ] \
     -t translation[ 0.1 ] \
     -c [$its,1.e-8,20]  \
    -s 6x4x3x2x2vox  \
    -f 12x8x6x4x2 -l 1 \
    -m mattes[  $fmask, $mmask, 1 , 32, regular, $percentage ] \
     -t rigid[ 0.1 ] \
     -c [$its,1.e-8,20]  \
    -s 4x3x2x2x2vox  \
    -f 8x6x4x2x1 -l 1 \
    -m mattes[  $fmask, $mmask, 1 , 32, regular, $percentage ] \
     -t affine[ 0.1 ] \
     -c [$its,1.e-8,20]  \
    -s 4x3x2x2x2vox  \
    -f 8x6x4x2x1 -l 1 \
    -m CC[  $f, $m , 1 , 2 ] \
     -t SyN[ .25, 6, 0 ] \
     -c [ 400x400x400x400x400x20,0,5 ]  \
    -s 6x4x3x2x1x1vox  \
    -f 12x8x6x4x2x1 -l 1 -u 1 -z 1 \
   -o ${nm}

  ${AP}antsApplyTransforms -d $dim -i $m -r $f -n linear -t ${nm}1Warp.nii.gz -t ${nm}0GenericAffine.mat -o ${nm}_warped.nii.gz
}

tic

FIX=$1
FIXMASK=$2
MOV=$3
MOVMASK=$4
OUTPUTDIR=$5

register_new_ants newants $FIX $FIXMASK $MOV $MOVMASK $OUTPUTDIR 

toc
