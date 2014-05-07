#!/bin/bash

# batch script to segment EduardoNewData
# module1: lung segmentation: (final result: smoothlungs ==> separate.nii.gz)


# to copy nifty files from nii/ to May_04_2014 directory
# for ((i=3; i<=10; i++)); do cp -r ../nii/N${i}/* . ; done;


# do i need to downsample the file to 256???

make_metric_dir(){

local RESDIR=$1

    if [ -f $RESDIR ]
    then
        echo 'As a file: ' $RESDIR
        rm $RESDIR
    fi

    if [ ! -d $RESDIR ]
    then
        echo creating $RESDIR
        mkdir $RESDIR
    fi
}


func(){
for mydate in $datelist
do
    echo process: $dbroot/$mydate    

    d$mydate

    for myimg in $imglist
    do
        echo ===========================================================
        echo image: $myimg
     
        
        # LUNGIMG=$dbroot/$mydate/$myimg/$myimg'.nii.gz'

        # LUNGNAME=$myimg'_downsampled'
        # LUNGIMG=$dbroot/$mydate/$myimg/$myimg'_downsampled.nii.gz'

        PADVOX=10
        RESDIR=$RESROOT/$myimg
        make_metric_dir $RESDIR

        LUNGNAME=$myimg'_down1p5mm'
        LUNGIMG=$RESDIR/$LUNGNAME'.nii.gz'               
        if [ ! -f $LUNGIMG ]; then echo "=====================" $LUNGIMG does not exist!; continue; fi
        qsub -S /bin/bash -N ${LUNGNAME}_pad -j y -wd $RESDIR pad.sh $RESDIR/$LUNGNAME'.nii.gz' $PADVOX $RESDIR/$LUNGNAME'_pad10.nii.gz'
        qsub -S /bin/bash -N ${LUNGNAME}_pad -j y -wd $RESDIR pad.sh $RESDIR/$LUNGNAME'_lungmask.nii.gz' $PADVOX $RESDIR/$LUNGNAME'_pad10_lungmask.nii.gz'
        qsub -S /bin/bash -N ${LUNGNAME}_pad -j y -wd $RESDIR pad.sh $RESDIR/$LUNGNAME'_lungs.nii.gz' $PADVOX $RESDIR/$LUNGNAME'_pad10_lungs.nii.gz'
        qsub -S /bin/bash -N ${LUNGNAME}_pad -j y -wd $RESDIR pad.sh $RESDIR/$LUNGNAME'_separate.nii.gz' $PADVOX $RESDIR/$LUNGNAME'_pad10_separate.nii.gz'
        qsub -S /bin/bash -N ${LUNGNAME}_pad -j y -wd $RESDIR pad.sh $RESDIR/$LUNGNAME'_smooth.nii.gz' $PADVOX $RESDIR/$LUNGNAME'_pad10_smooth.nii.gz'
        qsub -S /bin/bash -N ${LUNGNAME}_pad -j y -wd $RESDIR pad.sh $RESDIR/$LUNGNAME'_airways.nii.gz' $PADVOX $RESDIR/$LUNGNAME'_pad10_airways.nii.gz'


        LUNGNAME=$myimg'_downsampled'
        LUNGIMG=$RESDIR/$LUNGNAME'.nii.gz'               
        if [ ! -f $LUNGIMG ]; then echo "=====================" $LUNGIMG does not exist!; continue; fi
        qsub -S /bin/bash -N ${LUNGNAME}_pad -j y -wd $RESDIR pad.sh $RESDIR/$LUNGNAME'.nii.gz' $PADVOX $RESDIR/$LUNGNAME'_pad10.nii.gz'
        qsub -S /bin/bash -N ${LUNGNAME}_pad -j y -wd $RESDIR pad.sh $RESDIR/$LUNGNAME'_lungmask.nii.gz' $PADVOX $RESDIR/$LUNGNAME'_pad10_lungmask.nii.gz'
        qsub -S /bin/bash -N ${LUNGNAME}_pad -j y -wd $RESDIR pad.sh $RESDIR/$LUNGNAME'_lungs.nii.gz' $PADVOX $RESDIR/$LUNGNAME'_pad10_lungs.nii.gz'
        qsub -S /bin/bash -N ${LUNGNAME}_pad -j y -wd $RESDIR pad.sh $RESDIR/$LUNGNAME'_separate.nii.gz' $PADVOX $RESDIR/$LUNGNAME'_pad10_separate.nii.gz'
        qsub -S /bin/bash -N ${LUNGNAME}_pad -j y -wd $RESDIR pad.sh $RESDIR/$LUNGNAME'_smooth.nii.gz' $PADVOX $RESDIR/$LUNGNAME'_pad10_smooth.nii.gz'
        qsub -S /bin/bash -N ${LUNGNAME}_pad -j y -wd $RESDIR pad.sh $RESDIR/$LUNGNAME'_airways.nii.gz' $PADVOX $RESDIR/$LUNGNAME'_pad10_airways.nii.gz'

        
    done
done
}

# to obtain $dbroot $mydate $myimg 
. dblist.sh

RESROOT=/home/songgang/project/EduardoNewData/data/output
CURDIR=`pwd`
echo $datelist
func
