#!/bin/bash

sleep 0.5


# Subject and Session

subject_dir_name=$1
# Check our FSL instalation is found 

if [[ -z "$FSLDIR" ]]; then

echo -e "\033[31mError: No FSL Installation Found.\033[0m"
        exit 1
fi
# Check that centaur_constants.csv exist in current working directory

if [[ ! -f "centaur_constants.csv" ]]; then
    echo
    echo -e "\033[31mError: centaur_constants.csv Not Found.\033[0m"
    exit 1
else
centaur_constants=${PWD}/centaur_constants.csv
fi

# Find the Centaur ROIS in the path 
ROIS=$(find ./SPM -type f -name "*vlpp.nii.gz" ! -name "*1mm*")
ref=$(find  ./SPM -name "voi*1mm*vlpp.nii")

# Create a control structure for the ROIS

if [[ -z  "$ROIS" ]]; then 
    echo -e "\033[31mError: Centaur Masks Not Found.\033[0m"
    exit 1
fi 

# a new control structure to make sure that  the reference regions 
if [[ -z  "$ref" ]]; then 
    echo -e "\033[31mError: Reference Region Mask Not Found.\033[0m"
    exit 1

fi 


## Define the path to the prevent-ad data

prevent_ad=/project/rrg-villens/dataset/PreventAD/pet/derivatives/vlpp_preproc_2022/Nov2023/vlpp_tau/${subject_dir_name}

## finaly just check if prevent ad directory exists 

if [[ ! -d "$prevent_ad" ]]; then
echo -e "\033[31mError: Not vlpp Sourcedir Directory Found.\033[0m"
exit 0
fi

echo

echo ++ Stage 1: Creating a Directory Subject $subject_id.
	basedir=$PWD
    subject_dir="./outputs_vlpp/${subject_dir_name}" 
    sleep 0.5

# add a control structure to overwrite the files if necessary
 if [[ -d "$subject_dir" ]]; then
    echo +++ Subject Directory Exists! Files will be overwritten.
    rm -rf $subject_dir
    mkdir -p $subject_dir
 else
 mkdir -p $subject_dir

fi

# Search for the pet and anat and copy it to output dir
echo +++ Searching for T1w and PET Scan For Subject $subject_id...
sleep 0.5
	find $prevent_ad -name "*_T1w_space-tpl.nii.gz" -exec cp {} $subject_dir \;
	find $prevent_ad -name "**pet_time-4070_space-tpl.nii.gz" -exec cp {} $subject_dir \;

## cp centaur constants
cp centaur_constants.csv $subject_dir
cp extract_centaur_vlpp.R $subject_dir
cp $ROIS $subject_dir
cp $ref $subject_dir
# Add a control structure to terminate the program if files are not found
	cd $subject_dir
	 anat=$(ls | grep T1w)
	 pet=$( ls | grep pet)
 
echo ++ Stage2: Preparing The Files.
echo +++ Reorienting Files to MNI Space
sleep 1
fslreorient2std $anat $anat
fslreorient2std $pet $pet
	echo +++ Done!

echo ++ Stage3: Extracting  SUV and SUVr in CenTaur masks. 

# run the script 

Rscript 
cd $basedir
echo ++ FINISHED! 
exit 0   

