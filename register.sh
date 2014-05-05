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

function register_old_ants()
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

  reg=${AP}/ANTS
  
  
  nm=$OUTPUTDIR/${nm1}_fixed_${nm2}_moving_${casename}   # construct output prefix

  echo register fix $f 
  echo register mov $m 
  echo outname is $nm 

  ANTS 3 -o ${nm}_initaff\
    -m MSQ[$fmask,$mmask,1] \
    -i 0\
    -t SyN[0.25]\
    -r Gauss[6,0]\
    --affine-metric-type MI\
    --number-of-affine-iterations 10000x10000x10000x10000

  ANTS 3 -o ${nm}\
    -m CC[$f,$m,1,2]\
    -i 200x200x200x200x50\
    -t SyN[0.25]\
    -r Gauss[6,0]\
    --initial-affine ${nm}_initaffAffine.txt\
    --continue-affine false

  ${AP}antsApplyTransforms -d $dim -i $m -r $f -n linear -t ${nm}Warp.nii.gz -t ${nm}Affine.txt -o ${nm}_warped.nii.gz

}

tic

FIX=$1
FIXMASK=$2
MOV=$3
MOVMASK=$4
OUTPUTDIR=$5

register_old_ants oldants $FIX $FIXMASK $MOV $MOVMASK $OUTPUTDIR 

toc
