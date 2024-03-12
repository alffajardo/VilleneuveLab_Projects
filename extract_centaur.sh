#!/bin/bash


# Arguments 

# $1: Subjects directory basename : exmaple sub-0000_TAU_ses-01

sleep 0.5
subject_dir_name=$1

#remove slash... in case it exists
subject_dir_name=$(echo "$subject_dir_name" | sed -e 's/\///g')

# find the directory
subject_dir=$(find . -type d -name "$subject_dir_name" )

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
ROIS=$(find $PWD/SPM -type f -name "*nii.gz" ! -name "*2mm")
ref=$(find $PWD/SPM -name "*2mm*")

# Finally Just in case evaluate that pet correg pet in MNI exist

cd $subject_dir
pet=$(ls |  grep wsub |grep avg)

if [ -z $pet ]; then
    echo -e "\033[31mError: MNI-PET Scan Not Found in Subject's Directory.\033[0m"
    exit 1 
else
sleep 1 
echo  ++ Computing SUV, SUVr and Centaur Values...

fi

# Set up the temporary directory. 
echo ++ Preparing Files...
sleep 1

if [ ! -d "tmp" ]; then
mkdir tmp
else
echo ++ ./tmp Dir Exists!! Files Will Be Overwritten...
rm  -rf tmp/*
fi
cp $ROIS tmp
cp $ref tmp
cp $pet tmp

cd tmp
###
# Create the csv file 

echo "ID,name,SUVR,CentaurZ" > ${subject_dir_name}_CenTaur.csv

for roi in $ROIS; do

    roi_name=$(basename $roi | sed 's/_CenTaur.nii.gz//g')


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
    echo "$subject_dir_name,$roi_name,$suvr,$centaur" >> ${subject_dir_name}_CenTaur.csv
 
done 

cp  ${subject_dir_name}_CenTaur.csv ..
 cp ${subject_dir_name}_CenTaur.csv $basedir
 cd $basedir
 rm -r ${subject_dir}/tmp

echo ++ FINISHED! 
exit 0 
