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
     
        
        LUNGIMG=$dbroot/$mydate/$myimg/$myimg'.nii.gz'
        LUNGNAME=$myimg
        RESDIR=$RESROOT/$myimg
        LUNGMASK=$RESDIR/$myimg'_smooth.nii.gz'
        TMPDIR=$RESDIR/$myimg
        
        if [ ! -f $IMG ]; then echo $IMG does not exist!; continue; fi
        
        make_metric_dir $RESDIR		
        qsub -S /bin/bash -N ${LUNGNAME}_seglungc -wd $RESDIR seglungc.sh $LUNGIMG $RESDIR $LUNGMASK $LUNGNAME
    done
done
}

# to obtain $dbroot $mydate $myimg 
. dblist.sh

RESROOT=/home/songgang/project/EduardoNewData/data/output
CURDIR=`pwd`
echo $datelist
func