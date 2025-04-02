#!/bin/bash
# @Author: Alfonso Fajardo-Valdez
# Date: 25/01/2024
#Description: Normalise pet from the prvent ad to MNI space

# Define subject ID

subject=$1
tracer=$2 # NAV or TAU
session=$3 # ses-01 or ses-02


module load VilleneuveLab

# Path to the prevent-ad root directory 
PAD_PET="/project/rrg-villens/afajardo/PREVENT-AD_vlpp/derivatives/TAU/vlpp_fwhm04mm"


# define name of the warp file 

warp_name=${subject}_${tracer}_${session}_anat2tpl_Warp.nii

# define the correct pet file
if [ "$tracer" == "TAU" ]; then

    pet_name="${subject}_${tracer}_${session}_pet_time-4070_space-anat_ref-infcereg_suvr.nii"

elif [ "$tracer" == "NAV" ]; then

    pet_name="${subject}_${tracer}_${session}_pet_time-4070_space-anat_ref-cerebellumCortex_suvr.nii"
fi

echo $pet_name
echo $warp_name


# Create temporal directory

workdir=$PWD

tmp_dir=${PWD}/tmp.${subject}_${tracer}_${session}

mkdir $tmp_dir
cd $tmp_dir 

# find the path to PET 

pet_path=$(find $PAD_PET -name "${pet_name}.gz")

# find the warp file
warp_path=$(find $PAD_PET -name "${warp_name}.gz")

echo ++ PET: $pet_path
echo ++ WARP: $warp_path
echo 
sleep 1.2 
echo 

# copy and decompressed the files 

cp $pet_path $warp_path -t  $tmp_dir


#  decompress and reorient the files the pet file to standard space

echo 
echo ++ Reorienting the PET scan to standard space

cp  ${pet_name}.gz tmp_${pet_name}.gz

echo ++ Reorienting Done!



mv tmp_${pet_name} ${pet_name}.gz

## create the matlab batch  



gunzip *nii.gz

echo "%% A matlab script to normalise to MNI space


% define the path to the  nifti image

pet_file = 'PET_PATH'
% define the path to the warp (transformation params ) nifti file

warp_file = 'WARP_PATH'

% Inicialize SPM batch job
spm('Defaults', 'PET');
spm_jobman('initcfg');


% Load the PET scan
pet = spm_vol(pet_file);

% Load the warp file
warp = spm_vol(warp_file);

% Commands to normalise the file
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {pet_file};
matlabbatch{1}.spm.spatial.normalise.write.subj.def = {warp_file};
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -50; 78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 1;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = '2MNI_';


% run the matlab
spm_jobman('run', matlabbatch);" | \
sed "s/PET_PATH/${pet_name}/g" | \
sed "s/WARP_PATH/${warp_name}/g" > tmp.m

#cat ${subject}_${tracer}_${session}_pet2mni.m

# Execute the matlab batch


matlab -batch "run tmp.m"

# rename tmp file 

mv tmp.m ${subject}_${tracer}_${session}_pet2mni.m

# copy the outputs to the working directory

cp *.m 2MNI* -t  $workdir
cd ..
# rm -rf $tmp_dir


exit 0 
