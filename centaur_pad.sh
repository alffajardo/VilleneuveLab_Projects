#!/bin/bash

echo
echo

# Subject and Session

	subject_id=$1
	session=$2 # ses-01 or ses-02

# Define the path to the prevent-ad data

	prevent_ad=/project/rrg-villens/dataset/PreventAD/pet/derivatives/vlpp_preproc_2022/Nov2023/vlpp_tau

echo
echo ++ Step 1: Create a Directory for the participant $subject_id.
	basedir=$PWD
        subject_dir="${PWD}/outputs/${subject_id}_TAU_${session}/orig"


	mkdir -p $subject_dir

## Search for the Subject scans

echo
echo ++ Searching for T1w and PET scan for subject $subject_id...
	sleep 1s
	find $prevent_ad -name "${subject_id}*${session}_T1w.nii.gz" -exec cp {} $subject_dir \;
	find $prevent_ad -name "${subject_id}*${session}_pet.nii.gz" -exec cp {} $subject_dir \;

# Add a control structure to terminate the program if files are not found
	cd $subject_dir
	 anat=$(ls | grep T1w.nii.gz)
	 pet=$( ls | grep pet.nii.gz)
 # Check Anat
	if [[ -z "$anat" ]] ; then
		echo
		echo -e "\033[0;31m++ Error: T1w Scan not found  in working directory\e[0m"
		cd $basedir
                rm -r ${PWD}/outputs/${subject_id}_TAU_${session}
		exit 1
	fi
 # Check pet

	if [[ -z "$pet" ]] ; then
		echo
                echo -e "\033[0;31m++ Error: Tau PET Scan not found  in working directory\e[0m"
		cd $basedir
		rm -r ${PWD}/outputs/${subject_id}_TAU_${session}
               	exit 1
       	fi

echo
echo ++ Step2: Calculate  PET  time average.
 	echo  ++ Calculating average...
	 sleep 1s
  fslreorient2std $anat $anat
 fslreorient2std $pet $pet
  fslmaths $pet -Tmean ${subject_id}_TAU_${session}_pet_avg.nii.gz
 	echo 
	echo ++ Done!!

# Gunzip the files

echo -e "\033[1;33m"


	gunzip *.nii.gz
	anat=$(ls | grep T1w)
	pet=$(ls | grep avg.nii)
	sleep 2s
	echo Anat Basename: $anat
	echo Tau PET Basename: $pet

echo -e "\e[0m"

echo ++ Step3: Run the CenTaur Pipeline.
	cd ..
        output_dir=$PWD
	cd $basedir


echo ++ Launching MATLAB Script...
sleep 1s

cmd="SPM8_Centaur('${subject_dir}/${anat}','${subject_dir}/${pet}','FTP','$output_dir'); quit();"
echo "$cmd"
matlab -nodesktop -nodisplay -r "$cmd"
exit 0
