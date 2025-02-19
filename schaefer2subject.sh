#!/bin/bash

## Script Name: schaefer2subject.sh
## Description: Script to transform the Schaefer parcellation to subjects' anatomy with customizable parameters

# Load Apptainer module at the beginning
module load apptainer

container_path=/project/rrg-villens/afajardo/containers/freesurfer_v.5.5.0.sif
license_path=/project/rrg-villens/afajardo/containers/fs_license.txt

# Default parameters
DEFAULT_SUBJECTS_DIR="/project/rrg-villens/dataset/PreventAD/pet/derivatives/freesurfer_syms/Nov2023"
DEFAULT_CBIG_CODE_DIR="/project/rrg-villens/afajardo/github/CBIG"
DEFAULT_PARCELLS=200
DEFAULT_NETWORKS=7
DEFAULT_FSAVERAGE="fsaverage"
VALID_PARCELLS=(100 200 300 400 500 600 700 800 900 1000)
VALID_NETWORKS=(7 17)
VALID_FSAVERAGE=(fsaverage fsaverage5 fsaverage6)

# Help function
show_help() {
  echo "Script: schaefer2subject.sh"
  echo "Usage: $0 -s <subject> [-d <subjects_dir>] [-c <cbig_code_dir>] [-p <parcells>] [-n <networks>] [-f <fsaverage>]"
  echo "  -s <subject>       Subject ID (mandatory)"
  echo "  -d <subjects_dir>  Path to the subjects directory (default: $DEFAULT_SUBJECTS_DIR)"
  echo "  -c <cbig_code_dir> Path to CBIG_CODE_DIR (default: $DEFAULT_CBIG_CODE_DIR)"
  echo "  -p <parcells>      Number of parcels (valid: ${VALID_PARCELLS[*]}, default: $DEFAULT_PARCELLS)"
  echo "  -n <networks>      Number of networks (valid: ${VALID_NETWORKS[*]}, default: $DEFAULT_NETWORKS)"
  echo "  -f <fsaverage>     FSAVERAGE template (valid: ${VALID_FSAVERAGE[*]}, default: $DEFAULT_FSAVERAGE)"
  echo "  -h                 Show this help message"
  exit 0
}

# Parse options
if [ $# -eq 0 ]; then
  show_help
fi

while getopts "s:d:c:p:n:f:h" opt; do
  case ${opt} in
    s )
      subject=${OPTARG}
      ;;
    d )
      SUBJECTS_DIR=${OPTARG}
      ;;
    c )
      CBIG_CODE_DIR=${OPTARG}
      ;;
    p )
      PARCELLS=${OPTARG}
      if [[ ! " ${VALID_PARCELLS[*]} " =~ " ${PARCELLS} " ]]; then
        echo "Error: Invalid number of parcels. Choose from: ${VALID_PARCELLS[*]}"
        exit 1
      fi
      ;;
    n )
      NETWORKS=${OPTARG}
      if [[ ! " ${VALID_NETWORKS[*]} " =~ " ${NETWORKS} " ]]; then
        echo "Error: Invalid number of networks. Choose from: ${VALID_NETWORKS[*]}"
        exit 1
      fi
      ;;
    f )
      FSAVERAGE=${OPTARG}
      if [[ ! " ${VALID_FSAVERAGE[*]} " =~ " ${FSAVERAGE} " ]]; then
        echo "Error: Invalid FSAVERAGE template. Choose from: ${VALID_FSAVERAGE[*]}"
        exit 1
      fi
      ;;
    h )
      show_help
      ;;
    * )
      show_help
      ;;
  esac
done

# Check mandatory argument
if [ -z "$subject" ]; then
  echo "Error: Subject ID (-s) is required."
  show_help
fi

# Set default values if not provided
SUBJECTS_DIR=${SUBJECTS_DIR:-$DEFAULT_SUBJECTS_DIR}
CBIG_CODE_DIR=${CBIG_CODE_DIR:-$DEFAULT_CBIG_CODE_DIR}
PARCELLS=${PARCELLS:-$DEFAULT_PARCELLS}
NETWORKS=${NETWORKS:-$DEFAULT_NETWORKS}
FSAVERAGE=${FSAVERAGE:-$DEFAULT_FSAVERAGE}

# Verify paths and files exist
if [ ! -d "$SUBJECTS_DIR" ]; then
  echo "Error: SUBJECTS_DIR '$SUBJECTS_DIR' does not exist."
  exit 1
fi

if [ ! -d "$CBIG_CODE_DIR" ]; then
  echo "Error: CBIG_CODE_DIR '$CBIG_CODE_DIR' does not exist."
  exit 1
fi

# Load apptainer
cd $SUBJECTS_DIR

echo "++ Left Hemisphere..."
sleep 2s
singularity exec --cleanenv \
 -B $CBIG_CODE_DIR:$CBIG_CODE_DIR \
 -B $SUBJECTS_DIR:$SUBJECTS_DIR \
 -B $license_path:/opt/freesurfer/license.txt \
 --env SUBJECTS_DIR=$SUBJECTS_DIR \
  $container_path \
  mri_surf2surf --hemi lh \
  --srcsubject $FSAVERAGE \
  --trgsubject $subject \
  --sval-annot ${CBIG_CODE_DIR}/stable_projects/brain_parcellation/Schaefer2018_LocalGlobal/Parcellations/FreeSurfer5.3/$FSAVERAGE/label/lh.Schaefer2018_${PARCELLS}Parcels_${NETWORKS}Networks_order.annot \
  --tval ${SUBJECTS_DIR}/${subject}/label/lh.Schaefer2018_${PARCELLS}Parcels_${NETWORKS}Networks_order.annot

echo
echo "++ Right Hemisphere..."
sleep 2s
singularity exec --cleanenv \
 -B $CBIG_CODE_DIR:$CBIG_CODE_DIR \
 -B $SUBJECTS_DIR:$SUBJECTS_DIR \
 -B $license_path:/opt/freesurfer/license.txt \
 --env SUBJECTS_DIR=$SUBJECTS_DIR \
 $container_path \
  mri_surf2surf --hemi rh \
  --srcsubject $FSAVERAGE \
  --trgsubject $subject \
  --sval-annot ${CBIG_CODE_DIR}/stable_projects/brain_parcellation/Schaefer2018_LocalGlobal/Parcellations/FreeSurfer5.3/$FSAVERAGE/label/rh.Schaefer2018_${PARCELLS}Parcels_${NETWORKS}Networks_order.annot \
  --tval ${SUBJECTS_DIR}/${subject}/label/rh.Schaefer2018_${PARCELLS}Parcels_${NETWORKS}Networks_order.annot

exit

