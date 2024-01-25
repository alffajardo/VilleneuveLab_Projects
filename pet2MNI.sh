#!/bin/bash
# @Author: Alfonso Fajardo-Valdez
# Date: 25/01/2024
#Description: Normalise pet from the prvent ad to MNI space

# Define subject ID

subject=$1
session=$2 # ses-01 or ses-02
tracer=$3 # NAV or TAU



# Path to the prevent-ad root directory 
PAD_PET="/project/rrg-villens/dataset/PreventAD/pet/derivatives/vlpp_preproc_2022/Nov2023"


# define the correct pet file
if [ "$tracer" == "TAU" ]; then

    pet_name="${subject}_${tracer}_${session}_space-anat_ref-infcereg_suvr.nii.gz"

elif [ "$tracer" == "NAV" ]; then

    pet_name="${subject}_${tracer}_${session}_space-anat_ref-cerebellumCortex_suvr.nii.gz"
fi

echo $pet_name



# Create temporal directory

workdir=$PWD

tmp_dir=tmp.${subject}_${tracer}_${session}

mkdir $tmp_dir
cd $tmp_dir 

# find the path to PET 

pet_path=$(find $Pad_PET -name "$")

exit 0 
