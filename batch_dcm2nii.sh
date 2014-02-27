#!/bin/bash

#batch to convert dicom to nii.gz


DCM2NII=/home/songgang/pkg/mricron/dcm2nii
DCMINI=/home/songgang/project/EduardoNewData/script/Edudcm2nii.ini

#dicom directory
# $DICOMROOT/randname/CT_N2E/randname/randname/
#nii direcotry
# NIIROOT/N2/N2E

DICOMROOT=/home/songgang/project/EduardoNewData/data/input/DICOM/pg2
NIIROOT=/home/songgang/project/EduardoNewData/data/input/nii

for dcmA in `ls -d $DICOMROOT/download*`
do
	echo 
	echo directory: $dcmA

	a1=`ls -d $dcmA/CT_*`
	a=`basename $a1`
	if [[ $a =~ ^CT_.*[0-9]+.+$ ]]; then
		# echo "CT_N2E" | sed -n 's/CT_\(.*[0-9]\+\)[E|I]/\1/p'
		patient=`echo $a | sed -n 's/^CT_\(.*[0-9]\+\).\+$/\1/p'`
		imgname=`echo $a | sed -n 's/^CT_\(.*[0-9]\+.\+$\)/\1/p'`
		echo found patient: $patient
		echo found imgname: $imgname

		for b in `ls -d $a1/*`
		do
			for c in `ls -d $b/*`
			do
				dicomdir=$c
				echo found dicomdir: $c
				dcmcnt=`ls $c/*.dcm | wc -l`
				echo found total $dcmcnt .dcm files

				if (( $dcmcnt > 0 )); then

					niidir=$NIIROOT/$patient/$imgname
					echo target niidir: $niidir
					if [ ! -d $niidir ]; then 
						mkdir -p $niidir
					fi

					tmpdir=/dev/shm/songgang-dcm2nii/$patient/$imgname
					echo target tmpdir $tmpdir
					if [ ! -d $tmpdir ]; then 
						mkdir -p $tmpdir 
					else 
						rm -rf $tmpdir/*
					fi
					echo cleaned $tmpdir

					# main conversion here:
					$DCM2NII -b $DCMINI -o $tmpdir $dicomdir
					# touch $tmpdir/N2Etouch.nii.gz

					niicnt=`ls $tmpdir/*.nii.gz | wc -l`
					if [ $niicnt == 1 ]; then
						tmpniifile=`ls $tmpdir/*.nii.gz`
						dstniifile=$niidir/$imgname.nii.gz
						echo computed 1 nii file: $tmpniifile
						if [ -f $dstniifile ]; then
							echo warning!!!: $dstniifile exist!
							echo overwriting now!!!!
							echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						fi 
						mv $tmpniifile $dstniifile
						echo moved to $dstniifile
						echo check $dstniifile
						ls -hl $dstniifile
					else
						echo broken: found $niicnt .nii.gz files in $tmpdir
						echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					fi
					
					rm -rf $tmpdir
					echo removed $tmpdir

				else
					echo broken: No 2 .dcm files. Skip!!!!!!!!!!!!!!!!!!!!!!
				fi
				break
			done
			break
		done
		else
			echo broken: bad directory without proper files: $a1
			echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	fi
done

rm -rf /dev/shm/songgang-dcm2nii
echo removed /dev/shm/songgang-dcm2nii

# /home/songgang/pkg/mricron/dcm2nii -b /home/songgang/project/EduardoNewData/script/Edudcm2nii.ini -o /dev/shm  /home/songgang/project/EduardoNewData/data/input/DICOM/download20140223193851/CT_N2E/79069544/43105272