#!/bin/bash
# script to extract an S


#Define parent Directory
basedir=$PWD

sleep 0.5
subject_dir_name=$1


#remove slash... in case it exists
subject_dir_name=$(basename $subject_dir_name)
# find the directory
subject_dir=$(find  ./outputs_spm8 -type d -name "$subject_dir_name" )

echo $subject_dir
# Evaluate if Subject Directory Exists
if [[ ! -d $subject_dir ]]; then
echo
echo -e "\033[31mError: Subject Directory Not Found.\033[0m"
exit 1
fi

# Check our FSL instalation is found 

if [[ -z "$FSLDIR" ]]; then

echo -e "\033[31mError: No FSL Installation Found.\033[0m"
        exit 1
fi

#check Rscript installation

if [[  ! -f "$(which Rscript)" ]] ; then 

echo -e 
echo -e "\033[31mError: No Rscript Command Found.\033[0m"
        exit 1
fi

# find the directory and navigate into it

sleep 1
echo
echo ++ Starting...
echo +++ Input: $subject_dir_name
echo

#Define parent Directory
basedir=$PWD

# Check that centaur_constants.csv exist in current working directory

if [[ ! -f "centaur_constants.csv" ]]; then
    echo
    echo -e "\033[31mError: centaur_constants.csv Not Found.\033[0m"
    exit 1
else
centaur_constants=${PWD}/centaur_constants.csv
fi

# Find the Centaur ROIS in the path 
ROIS=$(find ./SPM -type f -name "*CenTaur*nii.gz" ! -name "*2mm")
ref=$(find  ./SPM -name "*2mm*")




# Finally Just in case evaluate that pet correg pet in MNI exist


cp $ref $subject_dir
cp centaur_constants.csv $subject_dir
cp extract_centaur_spm8.R $subject_dir
cp $ROIS  $subject_dir

cd $subject_dir



## rename rois
#mv CenTauR.nii Universal_CenTauR.nii
#mv Mesial_CenTauR.nii MesialTemporal_CenTauR.nii
#mv TP_CenTaur.nii TemporoParietal_CenTauR.nii
#mv Meta_CenTauR.nii MetaTemporal_CenTauR.nii
###

Rscript extract_centaur_spm8.R $subject_dir_name


echo ++ FINISHED!
exit 0
