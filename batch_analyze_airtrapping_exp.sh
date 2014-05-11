#!/bin/bash

# batch script to register EduardoNewData 
# updated: 
# try 1.5mm
# fix: exp
# mov: insp

# to be changed
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
        
        # use exp: fix, insp: mov
        fixname=`awk "{print $"$j"}" <<< $imglist`
        movname=`awk "{print $"$i"}" <<< $imglist`

        echo ===========================================================
        echo image fix mov: $fixname $movname

        #FIXLUNGNAME=$fixname'_down1p5mm'
        FIXLUNGNAME=$fixname'_downsampled'
        FIXLUNGIMG=$RESROOT/$fixname/$FIXLUNGNAME'.nii.gz'

        #MOVLUNGNAME=$movname'_down1p5mm'
        MOVLUNGNAME=$movname'_downsampled'
        MOVLUNGIMG=$RESROOT/$movname/$MOVLUNGNAME'.nii.gz'
        
        # RESDIR has all warped files
        # the output *.txt will be in $RESDIR
        RESDIR=$RESROOT/$fixname
        casename="oldants"

        if [ ! -f $FIXLUNGIMG ]; then echo $FIXLUNGIMG does not exist!; continue; fi
        if [ ! -f $MOVLUNGIMG ]; then echo $MOVLUNGIMG does not exist!; continue; fi
        
        make_metric_dir $RESDIR

        qsub -pe serial 1 -S /bin/bash -j y -N ${FIXLUNGNAME}_airtrapping -wd $RESDIR analyze_airtrapping_exp.sh $FIXLUNGIMG $MOVLUNGIMG $RESDIR $casename

    done
done
}

# to obtain $dbroot $mydate $myimg 
. dblist.sh

RESROOT=/home/songgang/project/EduardoNewData/data/output
CURDIR=`pwd`
echo $datelist
func
