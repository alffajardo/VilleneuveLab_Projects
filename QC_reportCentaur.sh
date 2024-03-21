#!/bin/bash
#Description: a wrapper for qc_spm.R 
# This file generates a markdown and a html file
# Run this with an

echo
# Subject dir 
subject_dir=$1
basedir=$PWD
dir=$(basename $subject_dir)

# a control structure for directory
if [ ! -d "$subject_dir" ] ; then 

    echo -e "\033[0;31mError: Directory Doesn't Exists!\033[0m"
    exit 1

fi

# Control structure to find Rscript
if [ ! -f "$(which Rscript)" ]; then

    echo -e "\033[0;31mError: Required Rscript Not Found!\033[0m"
    exit 1
fi

sleep 1
echo ++ QC report will be generated...
sleep 1
echo ++ Lauching Rscript...

# Run the script
Rscript qc_spm.R $subject_dir 

# rename the QC directory
mv ${subject_dir}/QC ${subject_dir}/${dir}_QC

if [ ! -d "${subject_dir}/${dir}_QC" ] ; then
    echo -e "\033[0;31mError: ${subject_dir}/QC Directory Not Found!\033[0m"
    exit 1
else 
   cd ${subject_dir}/${dir}_QC
   mkdir files
   mv *.png files
   mv *.gif files

fi

sleep 1
# ANAT 2 TPL
echo ++ Genarating Markdown File...
echo "# ${dir} Spatial Normalization" > ${dir}.md 
echo "## Anat To Template" >> ${dir}.md
echo "**Anat to Template**: Sagittal View" >> ${dir}.md
echo "

" >> ${dir}.md
echo "![](files/tpl_anat_sagittal.gif)" >> ${dir}.md
echo "

" >> ${dir}.md
echo "**Anat to Template**: Coronal View" >> ${dir}.md
echo "\\" >> ${dir}.md
echo "![](files/tpl_anat_coronal.gif)" >> ${dir}.md
echo "

" >> ${dir}.md
echo "**Anat to Template**: Axial View" >> ${dir}.md
echo "

" >> ${dir}.md
echo "![](files/tpl_anat_axial.gif)" >> ${dir}.md

# PET 2 ANAT
echo "

" >> ${dir}.md
echo "## PET to Anat" >> ${dir}.md
echo "**Anat to Template**: Sagittal View" >> ${dir}.md
echo "

" >> ${dir}.md
echo "![](files/anat_pet_sagittal.gif)" >> ${dir}.md
echo "

" >> ${dir}.md
echo "**PET to Anat**: Coronal View" >> ${dir}.md
echo "\\" >> ${dir}.md
echo "![](files/anat_pet_coronal.gif)" >> ${dir}.md
echo "

" >> ${dir}.md
echo "**PET to Anat**: Axial View" >> ${dir}.md
echo "

" >> ${dir}.md
echo "![](files/anat_pet_axial.gif)" >> ${dir}.md

# PET 2 TPL

echo "

" >> ${dir}.md
echo "## PET to Template" >> ${dir}.md
echo "**PET to Template**: Sagittal View" >> ${dir}.md
echo "

" >> ${dir}.md
echo "![](files/tpl_pet_sagittal.gif)" >> ${dir}.md
echo "

" >> ${dir}.md
echo "**PET to Template**: Coronal View" >> ${dir}.md
echo "\\" >> ${dir}.md
echo "![](files/tpl_pet_coronal.gif)" >> ${dir}.md
echo "

" >> ${dir}.md
echo "**PET to Template**: Axial View" >> ${dir}.md
echo "

" >> ${dir}.md
echo "![](files/tpl_pet_axial.gif)" >> ${dir}.md

echo "- - -
 --- " >> ${dir}.md
echo ++ Done!
sleep 1 
echo "++ Generating HTML Report..."
pandoc -f markdown ${dir}.md > ${dir}.html
sleep 1
echo ++Done!

echo "FINISHED!!!"
sleep 2 
cd $basedir

exit 0