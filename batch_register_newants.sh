#!/bin/bash

# batch script to register EduardoNewData 
# fix: insp
# mov: exp

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
    local let nb_img=`wc -w <<< $imglist`
    echo total $nb_img files
    local i
    for((i=1; i <= nb_img; i+=2 ))
    do
        local fixname
        local movname
        local j
        let j=$i+1

        fixname=`awk "{print $"$i"}" <<< $imglist`
        movname=`awk "{print $"$j"}" <<< $imglist`

        echo ===========================================================
        echo image fix mov: $fixname $movname

        FIXLUNGNAME=$fixname'_downsampled'
        FIXLUNGIMG=$RESROOT/$fixname/$FIXLUNGNAME'.nii.gz'
        FIXLUNGMASK=$RESROOT/$fixname/$FIXLUNGNAME'_lungmask.nii.gz'

        MOVLUNGNAME=$movname'_downsampled'
        MOVLUNGIMG=$RESROOT/$movname/$MOVLUNGNAME'.nii.gz'
        MOVLUNGMASK=$RESROOT/$movname/$MOVLUNGNAME'_lungmask.nii.gz'

        RESDIR=$RESROOT/$fixname
        
        if [ ! -f $FIXLUNGIMG ]; then echo $FIXLUNGIMG does not exist!; continue; fi
        if [ ! -f $MOVLUNGIMG ]; then echo $MOVLUNGIMG does not exist!; continue; fi
        
        make_metric_dir $RESDIR

        #old ants, 1mm resolution 32g * 25%=8g needs -pe serial 4
        #new ants, serial 4 not enough, increase to 7
        qsub -pe serial 7 -S /bin/bash -N ${fixname}_newants_register -wd $RESDIR register_newants.sh $FIXLUNGIMG $FIXLUNGMASK $MOVLUNGIMG $MOVLUNGMASK $RESDIR

    done
done
}

# to obtain $dbroot $mydate $myimg 
. dblist.sh

RESROOT=/home/songgang/project/EduardoNewData/data/output
CURDIR=`pwd`
echo $datelist
func
