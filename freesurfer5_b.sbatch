#!/bin/bash
#SBATCH --job-name=fs_batch
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=16:00:00
#SBATCH --account=def-villens
#SBATCH --output=/lustre03/project/6079513/afajardo/GAAIN_data/CenTauR/derivatives/freesurfer/mri2/log/%x-fsbatch-%j.out

# SUBJECT. Use the path to the full name of the NIFTI file, ex. sub-001_T1w.nii.gz.nii.gz

# load modules


 module --force purge
 module load apptainer-suid

# Path to the NIFTI T1w directory

 MRI_DIR=/project/rrg-villens/afajardo/GAAIN_data/CenTauR/Data/anat/mri2


# Define Container path and fslicense

 FS_CONTAINER=/project/rrg-villens/afajardo/containers/freesurfer_v.5.5.0.sif
 FS_LICENSE=/project/rrg-villens/afajardo/containers/fs_license.txt

# now the subjects dir and subject id

 SUBJECTS_DIR=/project/rrg-villens/afajardo/GAAIN_data/CenTauR/derivatives/freesurfer/mri2
 subject=$1
 subjid=$(echo $subject | sed 's/.nii.gz//g')


# once we defined the important varibles we run fresurfer within the conainer

 singularity exec --cleanenv  \
  -B /project/rrg-villens/afajardo:/project/rrg-villens/afajardo \
  -B $FS_LICENSE:/opt/freesurfer/license.txt \
  $FS_CONTAINER \
  recon-all -all \
  -qcache \
  -sd $SUBJECTS_DIR \
  -subjid $subjid \
  -i ${MRI_DIR}/${subject}

