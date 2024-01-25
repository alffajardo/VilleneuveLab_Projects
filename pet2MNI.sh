#!/bin/bash
# @Author: Alfonso Fajardo-Valdez
# Date: 25/01/2024
#Description: Normalise pet from the prvent ad to MNI space

# Define subject ID

subject=$1
tracer=$2 # NAV or TAU
session=$3 # ses-01 or ses-02



# Path to the prevent-ad root directory 
PAD_PET="/project/rrg-villens/dataset/PreventAD/pet/derivatives/vlpp_preproc_2022/Nov2023"


# define name of the warp file 

warp_name=${subject}_${tracer}_${session}_anat2tpl_Warp.nii.gz

# define the correct pet file
if [ "$tracer" == "TAU" ]; then

    pet_name="${subject}_${tracer}_${session}_pet_time-4070_space-anat_ref-infcereg_suvr.nii.gz"

elif [ "$tracer" == "NAV" ]; then

    pet_name="${subject}_${tracer}_${session}_pet_time-4070_space-anat_ref-cerebellumCortex_suvr.nii.gz"
fi

echo $pet_name
echo $warp_name


# Create temporal directory

workdir=$PWD

tmp_dir=tmp.${subject}_${tracer}_${session}

mkdir $tmp_dir
cd $tmp_dir 

# find the path to PET 

pet_path=$(find $PAD_PET -name "$pet_name")

# find the warp file
warp_path=$(find $PAD_PET -name "$warp_name")

echo ++ PET: $pet_path
echo ++ WARP: $warp_path
echo 
sleep 1.2 
echo 

# copy and decompressed the files 

cp $pet_path $warp_path -t  $PWD

gunzip *.nii.gz




exit 0 
