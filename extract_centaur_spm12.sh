#!/bin/bash
# script to extract an S


#Define parent Directory
basedir=$PWD

sleep 0.5
subject_dir_name=$1


#remove slash... in case it exists
subject_dir_name=$(basename $subject_dir_name)
# find the directory
subject_dir=$(find  ./outputs_spm12 -type d -name "$subject_dir_name" )

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


# Check that centaur_constants.csv exist in current working directory

if [[ ! -f "centaur_constants.csv" ]]; then
    echo
    echo -e "\033[31mError: centaur_constants.csv Not Found.\033[0m"
    exit 1
fi

cp centaur_constants.csv  $subject_dir
cp extract_centaur_spm12.R $subject_dir
cd $subject_dir
 
mv wMCALT_CenTaur.nii wMCALT_Universal_CenTauR.nii
mv wMCALT_Meta_CenTauR.nii wMCALT_MetaTemporal_CenTauR.nii
mv wMCALT_Mesial_CenTauR.nii wMCALT_MesialTemporal_CenTauR.nii
mv wMCALT_TP_CenTauR.nii wMCALT_TemporoParietal_CenTauR.nii
echo $subject_dir_name
# rename the unversal centaur roi



sleep 1 
echo  ++ Computing SUV, SUVr and Centaur Values...


Rscript extract_centaur_spm12.R $subject_dir_name

   
echo ++ FINISHED! 
exit 0 
