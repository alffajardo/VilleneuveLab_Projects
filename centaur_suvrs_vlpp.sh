#!/bin/bash

sleep 0.5
echo


# Subject and Session

	subject_id=$1
	session=$2 # ses-01 or ses-02

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
ROIS=$(find $PWD/SPM -type f -name "*vlpp.nii.gz" ! -name "*2mm")
ref=$(find $PWD/SPM -name "voi*vlpp.nii.gz")

## Define the path to the prevent-ad data

prevent_ad=/project/rrg-villens/dataset/PreventAD/pet/derivatives/vlpp_preproc_2022/Nov2023/vlpp_tau

echo ++ Stage 1: Creating a Directory Subject $subject_id.
	basedir=$PWD
        subject_dir="${PWD}/outputs_vlpp/${subject_id}_TAU_${session}"

 # add a control structure to overwrite the files if necessary
 if [[ -d $"subject_dir" ]]; then
    echo ++ Subject Directory Exists! Files will be overwritten.
    rm -rf $subject_dir
    mkdir -p $subject_dir  
fi

echo +++ Searching for T1w and PET Scan For Subject $subject_id...
	sleep 1s
	find $prevent_ad -name "${subject_id}*${session}_T1w.nii.gz" -exec cp {} $subject_dir \;
	find $prevent_ad -name "${subject_id}*${session}_pet.nii.gz" -exec cp {} $subject_dir \;

# Add a control structure to terminate the program if files are not found
	cd $subject_dir
	 anat=$(ls | grep T1w)
	 pet=$( ls | grep pet)
 
 # Check pet

	if [[ -z "$pet" ]] ; then
		echo
                echo -e "\033[0;31m++ Error: Tau PET Scan not found  in working directory\e[0m"
		cd $basedir
		rm -r ${PWD}/outputs/${subject_id}_TAU_${session}
               	exit 1
       	fi

echo ++ Stage2: Preparing The Files.
echo +++ Reorienting Files to MNI Space
sleep 1
fslreorient2std $anat $anat
fslreorient2std $pet $pet
	echo +++ Done!!

# Gunzip the files

echo -e "\033[1;33m"

	gunzip *.nii.gz
	anat=$(ls | grep T1w)
	pet=$(ls | grep pet)

# Stage 3

echo ++ Stage3: Computing SUV, SUVr and Centaur Z in masks. 

# Create the csv file 

echo "ID,name,SUVR,CentaurZ" > ${subject}_${session}_CenTaur_vlpp.csv


for roi in $ROIS; do

    roi_name=$(basename $roi | sed 's/_vlpp.nii.gz//g')


    # Get the slope and intercept for the equation

    # Extract the row where Tracer is equal to "FTP" and store it in a variable

    # Get the column number that contains the name ${roi_name}_slope

    ## Extract the Slope Value
    echo  ++ Retrieving $roi_name Centaur ROI Constants...
    sleep 1

    intercept_col=$(cat $centaur_constants | head -n 1 | sed 's/,/\n/g' | cat -n | grep ${roi_name}_inter | cut -f 1) 
    intercept_val=$(cat $centaur_constants | grep FTP | cut -d ',' -f $intercept_col)

    slope_col=$(cat $centaur_constants | head -n 1 | sed 's/,/\n/g' | cat -n | grep ${roi_name}_slope | cut -f 1) 
    slope_val=$(cat $centaur_constants | grep FTP | cut -d ',' -f $slope_col)

    # Start calculating the SUVr 
    # Mask the images
    fslmaths $pet -nan -mul $roi tmp1.nii.gz
    fslmaths $pet -nan -mul $ref tmp2.nii.gz


    # Store the mean values
    roi_val=$(fslstats tmp1.nii.gz -M )
    ref_val=$(fslstats tmp2.nii.gz -M)

    # Calculate SUVr 
    suvr=$(echo "$roi_val / $ref_val" | bc -l)

    # Calculating the Centaur Values
    centaur=$(echo "$suvr * $slope_val + $intercept_val" | bc -l)


    sleep 0.5
    echo
    echo +++ ROI: $roi_name  
    echo +++ Scan: $pet
    echo +++ Reference Mask: $(basename $ref)
    echo +++ Intercept: $intercept_val
    echo +++ Slope: $slope_val
    echo +++ SUVr: $suvr
    echo +++ CenTaur Z: $centaur
    echo
    echo

    sleep 1
    rm tmp*.nii.gz
    echo "$subject_dir_name,$roi_name,$suvr,$centaur" >> ${subject}_${session}_CenTaur_vlpp.csv
 
done 

 cp ${subject}_${session}_CenTaur_vlpp.csv $basedir
 cd $basedir
 rm -r ${subject_dir}/tmp

echo ++ FINISHED! 
exit 0 

