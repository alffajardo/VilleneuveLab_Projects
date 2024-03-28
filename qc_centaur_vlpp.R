#!/bin/Rscript

# Screen intetended to generate screenshots to evaluate the spatial normalization of the spm8 outputs



# 1.  load the packages essentially neurobase----
  library(neurobase)
  library(magrittr)
  library(viridis)
  library(scales)
  library(magick)
  library(stringr)

# Read the command arguments
arguments <- commandArgs(T)
#arguments <- "outputs_vlpp/sub-PADMTL0002_TAU_ses-01"

# 
  # a sequence to plot slices
  slices_axial <- as.integer(seq(25,70,length.out = 9))
  slices_sagittal	<- as.integer(seq(45,75,length.out = 9))
  slices_coronal  <- as.integer(seq(20,90,length.out = 9)) %>% rev

# create a gradient of transparencies to look at the overlayed images

alpha_gradient <- seq(0,1,length.out = 9) %>% round(., digits = 2)
  
  

# Step one define the output dir
basedir <- getwd()

work_dir <-  as.character(arguments)[1]
workdir_base <- basename(work_dir)


# subject 
subject <- unlist(strsplit(workdir_base,split = "_") )[1]
session <- unlist(strsplit(workdir_base,split = "_") )[3]

# read the spm template

template <- readNIfTI("SPM/template_vlpp.nii.gz", reorient = F)

# pet 

pet_string  <- "pet_time-4070_space-tpl"
pet.name <- list.files(work_dir, pattern = pet_string)
pet <- readNIfTI(paste(work_dir,pet.name,sep="/"),reorient = F)
pet[is.nan(pet)] <- 0

# normalize pet 

pet_norm <-( pet - min(pet)) / (max(pet) - min(pet))
#pet_norm [pet_norm <= 0.05] <- NA

# anat
anat_string <- "_T1w_space-tpl.nii.gz"
anat.name <- list.files(work_dir,pattern = anat_string)

anat <- readNIfTI(paste(work_dir,anat.name,sep="/"),reorient = F)
anat[is.nan (anat)] <- 0
r <- range(anat[anat !=0])
anat_norm <- (anat@.Data - r[1]) / (r[2] - r[1])
anat_norm <- niftiarr(img = anat, arr = anat_norm)
anat_norm [anat == 0 ] <- 0






# create a list for storing the generated images
setwd(work_dir)
dir.create(recursive = T,"QC")
setwd("QC")
# 2. Display anatomical----


for (i in 01:length(alpha_gradient)){

# Anat axial
index <- str_pad(as.character(i),width = 2,side = "left",pad = "0")

png(filename = paste("tpl_anat_axial_alpha_",index,".png",sep = ""),
      height = 10,
      width = 15,
      units = "cm",res = 200,
    antialias = "none")
overlay(template,
anat_norm,
NA.x = T,NA.y = T,
col.y = alpha(viridis(100),alpha_gradient[i]),
zlim.y = c(0.0, 0.45),
z = slices_axial,
plot.type = "single")

dev.off()

#anat saggittal 

png(filename = paste("tpl_anat_sagittal_alpha_",index,".png",sep = ""),
    height = 10,
    width = 15,
    units = "cm",res = 200,
    antialias = "none")

overlay(template,
        anat_norm,
        NA.x = T,NA.y = T,
        col.y = alpha(viridis(100),alpha_gradient[i]),
        zlim.y = c(0.0,0.45),
        z = slices_sagittal,
        plot.type = "single",
        plane = "sagittal")

dev.off()

# anat coronal 

png(filename = paste("tpl_anat_coronal_alpha_",index,".png",sep = ""),
    height = 10, 
    width = 15,
    units = "cm",res = 200,
    antialias = "none")

overlay(template,
        anat_norm,
        NA.x = T,NA.y = T,
        col.y = alpha(viridis(100),alpha_gradient[i]),
        zlim.y = c(0.0,0.45),
        z = slices_coronal,
        plot.type = "single",
        plane = "coronal",)
dev.off() 


}


# AXIAL ANAT GIF
anat.axial.names <- list.files(pattern = "tpl_anat_axial.*\\.png$")
anat_axial_imgs <- lapply(anat.axial.names, image_read)
anat_axial_joined1 <- image_join(anat_axial_imgs,rep(anat_axial_imgs[10],5))
anat_axial_joined <- image_join(anat_axial_joined1,rev(anat_axial_joined1))
anat_axial_animated <- image_animate(anat_axial_joined,fps=2)
image_write(anat_axial_animated,"tpl_anat_axial.gif")

## SAGITTAL ANAT GIF
anat.sagittal.names <- list.files(pattern = "tpl_anat_sagittal.*\\.png$")
anat_sagittal_imgs <- lapply(anat.sagittal.names, image_read)
anat_sagittal_joined <- image_join(anat_sagittal_imgs,rep(anat_sagittal_imgs[10],5))
anat_sagittal_animated <- image_animate(anat_sagittal_joined,fps=2)
image_write(anat_sagittal_animated,"tpl_anat_sagittal.gif")

## CORONAL GIF 


anat.coronal.names <- list.files(pattern = "tpl_anat_coronal.*\\.png$")
anat_coronal_imgs <- lapply(anat.coronal.names, image_read)
anat_coronal_joined1 <- image_join(anat_coronal_imgs,rep(anat_coronal_imgs[10],5))
anat_coronal_joined <- image_join(anat_coronal_joined1,rev(anat_coronal_joined1))
anat_coronal_animated <- image_animate(anat_coronal_joined,fps=2)
image_write(anat_coronal_animated,"tpl_anat_coronal.gif")


# 3. Display PET in ANAT ------

for (i in 1:length(alpha_gradient)){
# pet axial view
  
  index <- str_pad(as.character(i),width = 2,side = "left",pad = "0")
  
  png(filename = paste("anat_pet_axial_alpha_",index,".png",sep = ""),
      height = 10,
      width = 15,
      units = "cm",res = 200,
      antialias = "none")
  
overlay(anat,
pet_norm,
NA.x = T,NA.y = T,
col.y = alpha(plasma(100),alpha_gradient[i]),
zlim.y = c(0.05,1),
z = slices_axial, 
plot.type = "single",
mfrow = c(3,5))
dev.off()
## sagittal plane

png(filename = paste("anat_pet_sagittal_alpha_",index,".png",sep = ""),
    height = 10,
    width = 15,
    units = "cm",res = 200,
    antialias = "none")

overlay(anat,
pet_norm,
NA.x = T,NA.y = T,
col.y = alpha(plasma(100),alpha_gradient[i]),
zlim.y = c(0.05,1),
z = slices_sagittal,
plot.type = "single",
plane = "sagittal")
dev.off()


png(filename = paste("anat_pet_coronal_alpha_",index,".png",sep = ""),
    height = 10,
    width = 15,
    units = "cm",res = 200,
    antialias = "none")
# coronal view
overlay(anat,
pet_norm,
NA.x = T,NA.y = T,
col.y = alpha(plasma(100),alpha_gradient[i]),
zlim.y = c(0.05, 1),
z = slices_coronal,
plot.type = "single",
plane = "coronal")
dev.off()
}
# ANAT PET axial View
anat.pet.axial.names <- list.files(pattern = "anat_pet_axial.*\\.png$")
anat.pet_axial_imgs <- lapply(anat.pet.axial.names, image_read)
anat.pet_axial_joined1 <- image_join(anat.pet_axial_imgs,rep(anat.pet_axial_imgs[10],5))
anat.pet_axial_joined <- image_join(anat.pet_axial_joined1,rev(anat.pet_axial_joined1))
anat.pet_axial_animated <- image_animate(anat.pet_axial_joined,fps=2)
image_write(anat.pet_axial_animated,"anat_pet_axial.gif")

# ANAT PET Sagittal 

anat.pet.sagittal.names <- list.files(pattern = "anat_pet_sagittal.*\\.png$")
anat.pet_sagittal_imgs <- lapply(anat.pet.sagittal.names, image_read)
anat.pet_sagittal_joined1 <- image_join(anat.pet_sagittal_imgs,rep(anat.pet_sagittal_imgs[10],5))
anat.pet_sagittal_joined <- image_join(anat.pet_sagittal_joined1,rev(anat.pet_sagittal_joined1))
anat.pet_sagittal_animated <- image_animate(anat.pet_sagittal_joined,fps=2)
image_write(anat.pet_sagittal_animated,"anat_pet_sagittal.gif")

# ANAT PET Coronal
anat.pet.coronal.names <- list.files(pattern = "anat_pet_coronal.*\\.png$")
anat.pet_coronal_imgs <- lapply(anat.pet.coronal.names, image_read)
anat.pet_coronal_joined1 <- image_join(anat.pet_coronal_imgs,rep(anat.pet_coronal_imgs[10],5))
anat.pet_coronal_joined <- image_join(anat.pet_coronal_joined1,rev(anat.pet_coronal_joined1))
anat.pet_coronal_animated <- image_animate(anat.pet_coronal_joined,fps=2)
image_write(anat.pet_coronal_animated,"anat_pet_coronal.gif")



# 4. Display PET in template----

for (i in 1:length(alpha_gradient)){
  # pet axial view
  
  index <- str_pad(as.character(i),width = 2,side = "left",pad = "0")
  
  png(filename = paste("tpl_pet_axial_alpha_",index,".png",sep = ""),
      height = 10,
      width = 15,
      units = "cm",res = 200,
      antialias = "none")
  
  overlay(template,
          pet_norm,
          NA.x = T,NA.y = T,
          col.y = alpha(inferno(100),alpha_gradient[i]),
          zlim.y = c(0,1),
          z = slices_axial, 
          plot.type = "single",
          mfrow = c(3,5))
  dev.off()
  ## sagittal plane
  
  png(filename = paste("tpl_pet_sagittal_alpha_",index,".png",sep = ""),
      height = 10,
      width = 15,
      units = "cm",res = 200,
      antialias = "none")
  
  overlay(template,
          pet_norm,
          NA.x = T,NA.y = T,
          col.y = alpha(inferno(100),alpha_gradient[i]),
          zlim.y = c(0,1),
          z = slices_sagittal,
          plot.type = "single",
          plane = "sagittal")
  dev.off()
  
  
  png(filename = paste("tpl_pet_coronal_alpha_",index,".png",sep = ""),
      height = 10,
      width = 15,
      units = "cm",res = 200,
      antialias = "none")
  # coronal view
  overlay(template,
          pet_norm,
          NA.x = T,NA.y = T,
          col.y = alpha(inferno(100),alpha_gradient[i]),
          zlim.y = c(0, 1),
          z = slices_coronal,
          plot.type = "single",
          plane = "coronal")
  dev.off()
}
# tpl PET axial View
tpl.pet.axial.names <- list.files(pattern = "tpl_pet_axial.*\\.png$")
tpl.pet_axial_imgs <- lapply(tpl.pet.axial.names, image_read)
tpl.pet_axial_joined1 <- image_join(tpl.pet_axial_imgs,rep(tpl.pet_axial_imgs[10],5))
tpl.pet_axial_joined <- image_join(tpl.pet_axial_joined1,rev(tpl.pet_axial_joined1))
tpl.pet_axial_animated <- image_animate(tpl.pet_axial_joined,fps=2)
image_write(tpl.pet_axial_animated,"tpl_pet_axial.gif")

# tpl PET Sagittal 

tpl.pet.sagittal.names <- list.files(pattern = "tpl_pet_sagittal.*\\.png$")
tpl.pet_sagittal_imgs <- lapply(tpl.pet.sagittal.names, image_read)
tpl.pet_sagittal_joined1 <- image_join(tpl.pet_sagittal_imgs,rep(tpl.pet_sagittal_imgs[10],5))
tpl.pet_sagittal_joined <- image_join(tpl.pet_sagittal_joined1,rev(tpl.pet_sagittal_joined1))
tpl.pet_sagittal_animated <- image_animate(tpl.pet_sagittal_joined,fps=2)
image_write(tpl.pet_sagittal_animated,"tpl_pet_sagittal.gif")

# tpl PET Coronal
tpl.pet.coronal.names <- list.files(pattern = "tpl_pet_coronal.*\\.png$")
tpl.pet_coronal_imgs <- lapply(tpl.pet.coronal.names, image_read)
tpl.pet_coronal_joined1 <- image_join(tpl.pet_coronal_imgs,rep(tpl.pet_coronal_imgs[10],5))
tpl.pet_coronal_joined <- image_join(tpl.pet_coronal_joined1,rev(tpl.pet_coronal_joined1))
tpl.pet_coronal_animated <- image_animate(tpl.pet_coronal_joined,fps=2)
image_write(tpl.pet_coronal_animated,"tpl_pet_coronal.gif")

setwd(basedir)
