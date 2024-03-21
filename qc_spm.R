#!/bin/Rscript

# Screen intetended to generate screenshots to evaluate the spatial normalization of the spm8 outputs



# 1.  load the packages essentially neurobase
  library(neurobase)
  library(magrittr)
  library(oce)
  library(scales)

# Step one define the output dir
work_dir="outputs_spm8/sub-PADMTL0002_TAU_ses-01"
workdir_base <- basename(work_dir)

# subject 
subject <- unlist(strsplit(workdir_base,split = "_") )[1]
session <- unlist(strsplit(workdir_base,split = "_") )[3]

# read the spm template

template <- readNIfTI("./spm8/templates/T1.nii", reorient = F)

# pet 
pet.name  <- paste("w",subject,"_","TAU","_",session,"_","pet","_","avg","_","coregT1MNI.nii",sep = "")
pet <- readNIfTI(paste(work_dir,pet.name,sep="/"),reorient = F)
pet[is.nan(pet)] <- 0

# normalize pet 

pet_norm <-( pet - min(pet)) / (max(pet) - min(pet))
pet_norm [pet_norm <= 0.05] <- NA

# anat
anat.name <-paste("w",subject,"_","TAU","_",session,"_","T1w","_","coregMNI.nii",sep = "")
anat <- readNIfTI(paste(work_dir,anat.name,sep="/"),reorient = F)
anat[is.nan (anat)] <- 0
r <- range(anat[anat !=0])
anat_norm <- (anat@.Data - r[1]) / (r[2] - r[1])
anat_norm <- niftiarr(img = anat, arr = anat_norm)
anat_norm [anat == 0 ] <- 0

slices_axial <- as.integer(seq(25,70,length.out = 9))
slices_sagittal	<- as.integer(seq(45,75,length.out = 9))
slices_coronal  <- as.integer(seq(20,90,length.out = 9)) %>% rev


## Display anatomical

overlay(template,
anat_norm,
NA.x = T,NA.y = T,
col.y = alpha(oceColorsViridis(100),0.5),
zlim.y = c(0.0, 0.5),
z = slices_axial,
plot.type = "single")

# anat saggital view
overlay(template,
anat_norm,
NA.x = T,NA.y = T,
col.y = alpha(oceColorsViridis(100),0.5),
zlim.y = c(0.0,0.5),
z = slices_sagittal,
plot.type = "single",
plane = "sagittal")
# pet coronal view 
dev.new()
overlay(anat,
pet_norm,
NA.x = T,NA.y = T,
col.y = alpha(oceColorsJet(100),0.3),
zlim.y = c(0.05,0.5),
z = slices_axial, 
plot.type = "single",
mfrow = c(3,5))

## sagittal plane

overlay(anat,
pet_norm,
NA.x = T,NA.y = T,
col.y = alpha(oceColorsJet(100),0.3),
zlim.y = c(0.05,0.5),
z = slices_sagittal,
plot.type = "single",
plane = "sagittal")

slices_coronal	<- as.integer(seq(20,90,length.out = 9)) %>% rev


# coronal view
overlay(anat,
pet_norm,
NA.x = T,NA.y = T,
col.y = alpha(oceColorsJet(100),0.3),
zlim.y = c(0.05,0.5),
z = slices_coronal,
plot.type = "single",
plane = "coronal")



