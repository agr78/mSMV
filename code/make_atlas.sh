#! /bin/bash
# Make QSM template
# Alexandra G. Roberts
# 05/13/2025
# Cornell MRI Lab
# Please cite:
#
# A. G. Roberts et al., 
# "Maximum spherical mean value filtering for whole-brain QSM,", 
# Magn Reson Med, vol. 91, no. 4, pp. 1586-1597, Apr 2024, doi: 10.1002/mrm.29963.
# 
# Tustison NJ et al.,
# N4ITK: improved N3 bias correction. 
# IEEE Trans Med Imaging. 2010 Jun;29(6):1310-20. doi: 10.1109/TMI.2010.2046908.
# 
# B. B. Avants et al., 
# "The optimal template effect in hippocampus studies of diseased populations," 
# NeuroImage, vol. 49, no. 3, pp. 2457-2466, 2010, doi: 10.1016/j.neuroimage.2009.09.062.


# Read each subject ID
while read -r line; do
echo $line
prefix=${line#*./000000}
id=${prefix%/*}
echo "Beginning registration for $id"
# Check if bias correction was completed
if ! test -f ./n4bc/n4bc_$id.nii.gz; then
	    N4BiasFieldCorrection -d 3 -i ./orig/$id.nii.gz -o ./n4bc/mag_n4bc_$id.nii.gz
fi
# Check if brain has been extracted
if ! test -f ./xtracted/mag_$id"BrainExtractionBrain.nii.gz"; then
     antsBrainExtraction.sh -d 3 -a ./n4bc/mag_n4bc_$id.nii.gz \
    -e ~/atlas/MICCAI2012-Multi-Atlas-Challenge-Data/T_template0.nii.gz \
    -m ~/atlas/MICCAI2012-Multi-Atlas-Challenge-Data/T_template0_BrainCerebellumProbabilityMask.nii.gz \
    -o ./xtracted/mag_$id -f ~/atlas/MICCAI2012-Multi-Atlas-Challenge-Data/T_template0_BrainCerebellumRegistrationMask.nii.gz 
fi
done < /your/mGRE/magnitude/list
# Then in the ./xtracted directory, run
nohup antsMultivariateTemplateConstruction2.sh -d 3 -o mag -j 64 ./
