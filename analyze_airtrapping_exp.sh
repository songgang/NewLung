#!/bash

##
# updated: 2014 /05/ 6
# for Eduardo's new larger dataset
# need to skip airways for now??
# use airways segmentation for Nick's tool for now
# naming convention:
# all segmentation masks go to corresponding source image directory ($nm1dir and $nm2dir)
# all statistics (res-*.txt) fiels go to the registration directory ($RESDIR)

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

IMDILATE=/home/songgang/pkg/bin/imdilate
ANTSDIR=/home/songgang/project/ANTS/bin64
BINDIR=/home/songgang/project/tustison/Utilities/gccrel
C3D=/home/songgang/pkg/bin/c3d
MEDFILTER=/home/songgang/pkg/bin/MedianFilter

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

tic(){
START=$(date +%s)
}

toc(){
# START=$(date +%s)
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"
}


FIXLUNGIMG=$1
MOVLUNGIMG=$2
RESDIR=$3
casename=$4

nm1=` basename $FIXLUNGIMG | cut -d '.' -f 1 `
nm2=` basename $MOVLUNGIMG | cut -d '.' -f 1 `
nm=$RESDIR/${nm1}_fixed_${nm2}_moving_$casename
nm1dir=`dirname $FIXLUNGIMG`
nm2dir=`dirname $MOVLUNGIMG`

checkfile $FIXLUNGIMG
checkfile $MOVLUNGIMG
checkfile $nm'_warped.nii.gz'
checkfile $nm1dir/$nm1'_smooth.nii.gz'
checkfile $nm2dir/$nm2'_smooth.nii.gz'
checkfile $nm1dir/$nm1'_lungmask.nii.gz'
checkfile $nm2dir/$nm2'_lungmask.nii.gz'
 
tic 

#-1 .get warped inspiration to the expiration
# MYDO $ANTSDIR/WarpImageMultiTransform 3 $RESDIR/fixed_resampled.nii.gz $RESDIR/fixed_resampled_warped.nii.gz -R $RESDIR/moving_resampled.nii.gz -i $RESDIR/antsAffine.txt $RESDIR/antsInverseWarp.nii.gz
 


# 0 .get warped airway mask in the moving domain
MYDO $C3D $nm1dir/$nm1'_smooth.nii.gz' -threshold 4 4 1 0 -o $nm1dir/$nm1'_roughairwaysmask.nii.gz'
MYDO $IMDILATE $nm1dir/$nm1'_roughairwaysmask.nii.gz' 2 $nm1dir/$nm1'_roughairwaysmask_dilated.nii.gz'

MYDO $C3D $nm2dir/$nm2'_smooth.nii.gz' -threshold 4 4 1 0 -o $nm2dir/$nm2'_roughairwaysmask.nii.gz'
MYDO $IMDILATE $nm2dir/$nm2'_roughairwaysmask.nii.gz' 2 $nm2dir/$nm2'_roughairwaysmask_dilated.nii.gz'



# 1. generate vessel masks
MYDO $C3D $FIXLUNGIMG -threshold -300 Inf 1 0 $nm1dir/$nm1'_lungmask.nii.gz' -multiply -o $nm1dir/$nm1'_vesselmask.nii.gz'
MYDO $IMDILATE $nm1dir/$nm1'_vesselmask.nii.gz' 2 $nm1dir/$nm1'_vesselmask_dilated.nii.gz'

MYDO $C3D $MOVLUNGIMG -threshold -300 Inf 1 0 $nm2dir/$nm2'_lungmask.nii.gz' -multiply -o $nm2dir/$nm2'_vesselmask.nii.gz'
MYDO $IMDILATE $nm2dir/$nm2'_vesselmask.nii.gz' 2 $nm2dir/$nm2'_vesselmask_dilated.nii.gz'

# 1. get aerated area in expiration: exclude airway and vessels
AEROTHRES=-500; #below
MYDO $C3D $nm1dir/$nm1'_lungmask.nii.gz' $nm1dir/$nm1'_roughairwaysmask_dilated.nii.gz' -scale -1 -shift 1 -multiply $nm1dir/$nm1'_vesselmask_dilated.nii.gz' -scale -1 -shift 1 -multiply $FIXLUNGIMG -threshold -Inf $AEROTHRES 1 0 -multiply -o $nm1dir/$nm1'_aerotedmask.nii.gz'
MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $nm1dir/$nm1'_aerotedmask.nii.gz' > $RESDIR/res"-exp-aeroted-Volume.txt"

MYDO $C3D $nm2dir/$nm2'_lungmask.nii.gz' $nm2dir/$nm2'_roughairwaysmask_dilated.nii.gz' -scale -1 -shift 1 -multiply $nm2dir/$nm2'_vesselmask_dilated.nii.gz' -scale -1 -shift 1 -multiply $MOVLUNGIMG -threshold -Inf $AEROTHRES 1 0 -multiply -o $nm2dir/$nm2'_aerotedmask.nii.gz'
MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $nm2dir/$nm2'_aerotedmask.nii.gz' > $RESDIR/res"-insp-aeroted-Volume.txt"

#   2. emphysema area or non-emphysema with severe air trapping ( threshold < -850 ) in expiration
EXPEMPHYSEMATHRES=-850; #below
MYDO $C3D $FIXLUNGIMG -threshold -Inf $EXPEMPHYSEMATHRES 1 0 $nm1dir/$nm1'_aerotedmask.nii.gz' -multiply -o $nm1dir/$nm1'_severemask.nii.gz'
MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $nm1dir/$nm1'_severemask.nii.gz' >  $RESDIR/res"-exp-severe-Volume.txt"

#   recompute: 2.1. emphysema area or non-emphysema with severe air trapping ( threshold < -950 ) in inspiration
INSPEMPHYSEMATHRES=-950
MYDO $C3D $MOVLUNGIMG -threshold -Inf $INSPEMPHYSEMATHRES 1 0 $nm2dir/$nm2'_aerotedmask.nii.gz' -multiply -o $nm2dir/$nm2'_severemask.nii.gz'
MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $nm2dir/$nm2'_severemask.nii.gz' >  $RESDIR/res"-insp-severe-Volume.txt"

# 5. compute the differencing image of warped inspiration to expiration
MYDO $C3D $nm'_warped.nii.gz' -scale -1 $FIXLUNGIMG -add -o $nm'_diff.nii.gz'
MYDO $MEDFILTER $nm'_diff.nii.gz' $nm'_diff_median.nii.gz' 2.0

# 6.0 compute the non severe region (dynamic AT should be inside non severe)
MYDO $C3D $nm1dir/$nm1'_aerotedmask.nii.gz' $nm1dir/$nm1'_severemask.nii.gz' -scale -1 -add -o $nm1dir/$nm1'_nonseveremask.nii.gz'


#   6. dynamic air trapping ( try various thrsholds on the differencing image)
dynamic_threshold_list=(5 25 50 75 100 125 150 175 200 225 250 275 300)
num_threshold=${#dynamic_threshold_list[*]}

for ((i=0; i < num_threshold; i++))
do
    T=${dynamic_threshold_list[i]}
    
    MYDO $C3D $nm'_diff_median.nii.gz' -threshold 0 $T 1 0 $nm1dir/$nm1'_nonseveremask.nii.gz' -multiply -o $nm"_moving_dynamic_$T.nii.gz"
    MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $nm"_moving_dynamic_$T.nii.gz" > $RESDIR/res-moving-dynamic"-"$T"-Median-Volume.txt" 
done 	


toc
