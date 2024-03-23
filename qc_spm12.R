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

 
# create a gradient of transparencies to look at the overlayed images

alpha_gradient <- seq(0,1,length.out = 10) %>% round(., digits = 2)
  
  

# Step one define the output dir
basedir <- getwd()

#work_dir <-  as.character(arguments)[1]
work_dir <- as.character(arguments[1])
workdir_base <- basename(work_dir)


# subject 
subject <- unlist(strsplit(workdir_base,split = "_") )[1]
session <- unlist(strsplit(workdir_base,split = "_") )[3]


# no need to read the template

# pet 
pet.name  <- list.files(work_dir,pattern = "*pet_avg_coregT1\\.nii$")[1]
pet <- readNIfTI(paste(work_dir,pet.name,sep="/"),reorient = F)
pet[is.nan(pet)] <- 0



# normalize pet 

pet_norm <-( pet - min(pet)) / (max(pet) - min(pet))



# anat
anat.name <- paste(subject,"TAU",session,"T1w.nii",sep = "_")
anat <- readNIfTI(paste(work_dir,anat.name,sep="/"),reorient = F)
anat[is.nan (anat)] <- 0
r <- range(anat[anat !=0])
anat_norm <- (anat@.Data - r[1]) / (r[2] - r[1])
anat_norm <- niftiarr(img = anat, arr = anat_norm)
anat_norm [anat == 0 ] <- 0
mask <- anat_norm
mask[mask != 0 ] <- 1
pet_norm <- mask_img(pet_norm,mask = mask )
pet_norm[pet_norm <= 0.1] <- 0

origin <-  round (cog(anat_norm))
x <- origin[1]
y <- origin[2]
z <- origin[3]

## read all the rois

centaur_mask.name <-paste(work_dir,"wMCALT_CenTauR.nii", sep = "/")
centaur_mask <- readNIfTI(centaur_mask.name,reorient = F)
refmask.name <- paste(work_dir,"wMCALT_voi_CerebGry_tau_2mm.nii", sep = "/")
refmask <- readNIfTI(refmask.name,reorient = F) * 2


all_rois <- centaur_mask + refmask
# now we merge the ROIS into a sigle file




slices_sagittal	<- as.integer(seq(x,x+60,length.out = 9))
slices_axial <- as.integer(seq(z+5,z+80,length.out = 9))
slices_coronal  <- as.integer(seq(y-80,y+20,length.out = 9)) %>% rev





# create a list for storing the generated images
setwd(work_dir)
dir.create(recursive = T,"QC")
setwd("QC")

# output the ROIS 
png(filename = paste(workdir_base,"_ROIS",".png",sep = ""),
    width = 15,height = 10,units = "cm",res = 200)

ortho2(anat_norm,all_rois,col.y = c("orange","green"),
       crosshairs = F,mfrow = c(1,3))

dev.off()


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
zlim.y = c(0.1, 1),
z = slices_coronal,
plot.type = "single",
plane = "coronal")
dev.off()
}
# ANATPET axial View
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



setwd(basedir)
