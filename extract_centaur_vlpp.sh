#!/bin/bash

sleep 0.5


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
ROIS=$(find $PWD/SPM -type f -name "*vlpp.nii.gz" ! -name "*1mm")
ref=$(find $PWD/SPM -name "voi*1mm*vlpp.nii")

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

prevent_ad=/project/rrg-villens/dataset/PreventAD/pet/derivatives/vlpp_preproc_2022/Nov2023/vlpp_tau/${subject_id}_TAU_${session}

## finaly just check if prevent ad directory exists 

if [[ ! -d "$prevent_ad" ]]; then
echo -e "\033[31mError: Not vlpp Sourcedir Directory Found.\033[0m"
exit 0
fi

echo

echo ++ Stage 1: Creating a Directory Subject $subject_id.
	basedir=$PWD
    subject_dir="${PWD}/outputs_vlpp/${subject_id}_TAU_${session}" 
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
	find $prevent_ad -name "${subject_id}*${session}_T1w_space-tpl.nii.gz" -exec cp {} $subject_dir \;
	find $prevent_ad -name "${subject_id}*${session}*pet_time-4070_space-tpl.nii.gz" -exec cp {} $subject_dir \;


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
	echo +++ Done!

echo ++ Stage3: Extracting  SUV and SUVr in CenTaur masks. 

echo "ID,name,SUVR,CentaurZ" > ${subject_id}_TAU_${session}_CenTaur_vlpp.csv

for roi in $ROIS; do

    roi_name=$(basename $roi | sed 's/_vlpp.nii.gz//g')

## Extract the Slope Value
    echo  +++ Retrieving $roi_name Centaur ROI Constants...
    sleep 0.5

    intercept_col=$(cat $centaur_constants | head -n 1 | sed 's/,/\n/g' | cat -n | grep ${roi_name}_inter | cut -f 1) 
    intercept_val=$(cat $centaur_constants | grep FTP | cut -d ',' -f $intercept_col)

    slope_col=$(cat $centaur_constants | head -n 1 | sed 's/,/\n/g' | cat -n | grep ${roi_name}_slope | cut -f 1) 
    slope_val=$(cat $centaur_constants | grep FTP | cut -d ',' -f $slope_col)

    echo +++ Computing SUVr...
    sleep 0.5

    fslmaths $pet -nan -mul $roi tmp1.nii.gz
    fslmaths $pet -nan -mul $ref tmp2.nii.gz

    # Store the mean values
    roi_val=$(fslstats tmp1.nii.gz -M )
    ref_val=$(fslstats tmp2.nii.gz -M)

    # Calculate SUVr 
    suvr=$(echo "$roi_val / $ref_val" | bc -l)

     centaur=$(echo "$suvr * $slope_val + $intercept_val" | bc -l)


    sleep 0.5
    echo
    echo +++ ROI: $roi_name  
    echo +++ Scan: $pet
    echo +++ Reference Mask: $(basename $ref)
    echo +++ Intercept: $intercept_val
    echo +++ Slope: $slope_val
    echo +++ CenTaur Z: $centaur
    echo
    echo
   
   sleep 1
    rm tmp*.nii.gz
    echo "$subject_id,$roi_name,$suvr,$centaur" >> ${subject_id}_TAU_${session}_CenTaur_vlpp.csv
   
done

 cp ${subject_id}_TAU_${session}_CenTaur_vlpp.csv $basedir
 cd $basedir
echo ++ FINISHED! 
exit 0   

