#!/bash

# mark:
# register_maskaff was used SUCCESSFULLY to register 
#   (use masks of lungs to initialize the affine transform)
# analyze airtrapping in the expiration domain
#  to be run on picsl clusters

# update: 2010 / Mar / 31
# compute the severe / nonsever / dynamic AT in the expiration domain
#
# updated: 2009 / Oct / 9
# created airway mask: XXX_airways.nii.gz in reg2/exp2insp and need to exclude airway from
#   lung regions.
#   needs: $OLDRESDIR/mask_resampled.nii.gz  -multiply $OLDRESDIR/fixed_resampled.nii.gz
#
# This script performs the following operations:
#  from the inspiration image, get segmentation mask of 
#   1. non-aerated area ( threshold > 0 HU ?)
#   2. emphysema area or non-emphysema with severe air trapping ( threshold < -910 )
#  from the registration field
#   4. compute warped expiration image
#	5. compute the differencing image of inspiration to the warped expiration
#     5.1 use Median filter to smooth out the image
#   6. dynamic air trapping ( try various thrsholds on the differencing image)
#  compute the volume of
#   aerated v0 = #1 (the whole lung should be computed, v0 should be whole lung - vessle only )
#   emphysema v1 = #2 in #1
#   dynamic_air_trapping v2 = #6 in (!#2 in #1)
#   total_air_trapping v3 = v1 + v2
# 
#   for matlab
#   correlation v1, v2, v3 / v0 with PFT 


# DO NOT WRITE # $ and together
##


RESDIR=$1



# ANTSDIR=/mnt/data1/tustison/PICSL/ANTS/bin64
# BINDIR=/mnt/data1/tustison/Utilities/bin64
# C3D=/mnt/aibs1/songgang/pkg/bin/c3d
# C3D=/mnt/aibs1/songgang/project/c3d/gccrel-x32/c3d
# MEDFILTER=/mnt/aibs1/songgang/project/imgfea/gccrel-x64nothread/MedianFilter


IMDILATE=/home/songgang/pkg/bin/imdilate
ANTSDIR=/home/songgang/project/ANTS/bin64
BINDIR=/home/songgang/project/tustison/Utilities/bin64
C3D=/home/songgang/pkg/bin/c3d
MEDFILTER=/home/songgang/pkg/bin/MedianFilter


# DO=echo
DO=myecho
EDO=emptyecho


function checkfile
{
    local myfile=$1
    if [ ! -f $myfile ]
    then
        echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        echo $myfile 'DOES NOT EXIST!!!'
        echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    exit
    fi
}

MYDO(){
# echo "-------------------------------------------------"
# echo $*
# echo "-------------------------------------------------"
 $*
# echo ">>>>>>>>> DONE <<<<<<<<<<<<<<<<"
}


function myecho
{
    echo
    echo $*
    # time $1
    $*
}

tic(){
START=$(date +%s)
}

toc(){
# START=$(date +%s)
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"
}


function emptyecho
{
    # echo
    # echo $*
    # time $1
    # $1
    # $*
    echo $1
}

checkfile $RESDIR/fixed_resampled.nii.gz
checkfile $RESDIR/moving_resampled.nii.gz
checkfile $RESDIR/antsAffine.txt
checkfile $RESDIR/antsInverseWarpxvec.nii.gz
checkfile $RESDIR/fixed_airway_resampled.nii.gz
checkfile $RESDIR/moving_mask_resampled.nii.gz

echo "have all needed files"

echo here
 
tic 

#-1 .get warped inspiration to the expiration
MYDO $ANTSDIR/WarpImageMultiTransform 3 $RESDIR/fixed_resampled.nii.gz $RESDIR/fixed_resampled_warped.nii.gz -R $RESDIR/moving_resampled.nii.gz -i $RESDIR/antsAffine.txt $RESDIR/antsInverseWarp.nii.gz


# 0 .get warped airway mask in the moving domain
MYDO $ANTSDIR/WarpImageMultiTransform 3 $RESDIR/fixed_airway_resampled.nii.gz $RESDIR/moving_airway_resampled_fake.nii.gz -R $RESDIR/moving_resampled.nii.gz -i $RESDIR/antsAffine.txt $RESDIR/antsInverseWarp.nii.gz

# 1. get aerated area in expiration: exclude airway and vessels

MYDO $IMDILATE $RESDIR/moving_airway_resampled_fake.nii.gz 2 $RESDIR/moving_airway_resampled_fake_dilated.nii.gz
MYDO $C3D $RESDIR/moving_airway_resampled_fake_dilated.nii.gz -o $RESDIR/moving_airway_resampled_fake_dilated.nii.gz
MYDO $C3D $RESDIR/moving_resampled.nii.gz -threshold -300 Inf 1 0 -o $RESDIR/moving_vessel_resampled.nii.gz
MYDO $IMDILATE $RESDIR/moving_vessel_resampled.nii.gz 2 $RESDIR/moving_vessel_resampled_dilated.nii.gz
MYDO $C3D $RESDIR/moving_mask_resampled.nii.gz $RESDIR/moving_airway_resampled_fake_dilated.nii.gz -scale -1 -shift 1 -multiply $RESDIR/moving_vessel_resampled_dilated.nii.gz -scale -1 -shift 1 -multiply $RESDIR/moving_resampled.nii.gz -threshold -Inf -500 1 0 -multiply -o $RESDIR/moving_aeroted_mask_resampled.nii.gz

MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $RESDIR/moving_aeroted_mask_resampled.nii.gz > $RESDIR/res"-moving-aeroted-Volume.txt"


#   2. emphysema area or non-emphysema with severe air trapping ( threshold < -850 ) in expiration
MYDO $C3D $RESDIR/moving_resampled.nii.gz -threshold -Inf -850 1 0 $RESDIR/moving_aeroted_mask_resampled.nii.gz -multiply -o $RESDIR/moving_severe_resampled.nii.gz
MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $RESDIR/moving_severe_resampled.nii.gz >  $RESDIR/res"-moving-severe-Volume.txt"

#   recompute: 2.1. emphysema area or non-emphysema with severe air trapping ( threshold < -950 ) in inspiration
MYDO $C3D $RESDIR/fixed_resampled.nii.gz -threshold -Inf -950 1 0 $RESDIR/moving_aeroted_mask_resampled -multiply -o $RESDIR/severe_resampled.nii.gz
MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $RESDIR/severe_resampled.nii.gz >  $RESDIR/res"-severe-Volume.txt"


#   5. compute the differencing image of warped inspiration to expiration
MYDO $C3D $RESDIR/fixed_resampled_warped.nii.gz -scale -1 $RESDIR/moving_resampled.nii.gz -add -o $RESDIR/moving_diff_resampled.nii.gz
MYDO $MEDFILTER $RESDIR/moving_diff_resampled.nii.gz $RESDIR/moving_diff_resampled_median.nii.gz 2.0


# 6.0 compute the non severe region (dynamic AT should be inside non severe)
MYDO $C3D $RESDIR/moving_aeroted_mask_resampled.nii.gz $RESDIR/moving_severe_resampled.nii.gz -scale -1 -add -o $RESDIR/moving_nonsevere_resampled.nii.gz

#   6. dynamic air trapping ( try various thrsholds on the differencing image)

dynamic_threshold_list=(5 25 50 75 100 125 150 175 200 225 250 275 300)
num_threshold=${#dynamic_threshold_list[*]}

for ((i=0; i < num_threshold; i++))
do
    T=${dynamic_threshold_list[i]}
    
    MYDO $C3D $RESDIR/moving_diff_resampled_median.nii.gz -threshold 0 $T 1 0 $RESDIR/moving_nonsevere_resampled.nii.gz -multiply -o $RESDIR/moving-dynamic"-"$T"_resampled.nii.gz"
    MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $RESDIR/moving-dynamic"-"$T"_resampled.nii.gz" > $RESDIR/res-moving-dynamic"-"$T"-Median-Volume.txt" 
#    MYDO rm $RESDIR/moving-dynamic"-"$T"_resampled.nii.gz"

done 	


toc
