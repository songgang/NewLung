NewLung
=======

The project to analyze the new lung data sets.

1. convert dicom to nii.gz
batch_dcm2nii.sh (change directory inside this script)

2. resample to 1mm
batch_resample.sh dblist_vol.sh

3. segment lung masks
batch_seglungc.sh dblist_vol.sh

4. register
batch_register.sh dblist_vol.sh

5. analyze volume of different thresholding
batch_analyze_airtrapping_exp.sh dblist_vol.sh

6. compute correlation
in matlab...