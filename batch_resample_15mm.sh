#!/bin/bash

# batch script to resample EduardoNewData

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
     
        
        #LUNGIMG=$dbroot/$mydate/$myimg/$myimg'.nii.gz'
        LUNGIMG=/home/songgang/project/EduardoNewData/data/input/May_04_2014/$myimg/$myimg'.nii.gz'
        RESDIR=$RESROOT/$myimg
        RESIMG=$RESDIR/$myimg'_down1p5mm.nii.gz'
        
        if [ ! -f $LUNGIMG ]; then echo $LUNGIMG does not exist!; continue; fi
        
        make_metric_dir $RESDIR		
        qsub -S /bin/bash -N ${myimg}_1p5mm_resample -wd $RESDIR resample_15mm.sh $LUNGIMG $RESIMG

    done
done
}

# to obtain $dbroot $mydate $myimg 
. dblist.sh

RESROOT=/home/songgang/project/EduardoNewData/data/output
CURDIR=`pwd`
echo $datelist
func
