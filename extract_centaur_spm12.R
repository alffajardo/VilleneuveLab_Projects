#!/usr/bin/Rscript

## later we will figure out the PET

# working dir will be taken from the command args


library(neurobase)
library(tidyverse)



basedir <- getwd()

# Process the centur thing 
centaur_constants <- read.csv("centaur_constants.csv") %>%
                    filter(Tracer == "FTP") 
slopes <- centaur_constants %>%
          select(ends_with("slope")) %>% 
       pivot_longer(values_to = "slope",
                    names_to = "ROI", cols = everything()) %>%
      mutate(ROI = str_remove(ROI,"_slope") )

centaur_constants2 <- centaur_constants %>%
  select(ends_with("_inter")) %>% 
  pivot_longer(values_to = "Intercept",
               names_to = "ROI", cols = everything()) %>%
  mutate(ROI = str_remove(ROI,"_inter") ) %>%
  full_join(slopes)

centaur_constants <- centaur_constants2

rm(centaur_constants2)

args <- commandArgs(trailingOnly = T)

ID <- as.character(args)[1]
#ID <- "sub-PADMTL0002_TAU_ses-01"

pet_string <- "_pet_avg_coregT1.nii"
roi_string <- "wMCALT"
ref<- "wMCALT_voi_CerebGry_tau_2mm.nii"

# Basedir directory  

# set working directory


# PET NAME 
pet_name <- dir(pattern = pet_string)[1]
roi_names <- dir(pattern = roi_string)
roi_names <- setdiff(roi_names,ref)

# read the pet 

# edit the roi names 

roi_names2 <- roi_names %>% 
 str_split( pattern = "_",simplify = T) %>%
  as.data.frame() %>%
  select(2) %>%
  c() %>%
  unlist(use.names = F)

pet <- readNIfTI(pet_name, reorient = F)

pet[is.nan(pet)] <- NA

ref <- readNIfTI(ref, reorient = F)
rois <- lapply(roi_names,readnii) %>%
        set_names(roi_names2)


extract_SUVr <- function(pet_scan, ref_mask ,mask){
  
  r <-  mean(pet_scan[ref_mask != 0],na.rm = T)
  m <-  mean (pet_scan[mask != 0 ],na.rm = T)
  suvr <- m / r 
  return(suvr)
  
}

roi_names2

# subjects data.frame
subject_data <- map(rois, ~extract_SUVr(pet_scan =  pet,
                            ref_mask = ref,
                             mask = .x)) %>%
  data.frame() %>% 
  pivot_longer(
    values_to = "SUVR", 
    names_to = "ROI", everything()) %>%
  inner_join(centaur_constants,.) %>%
  data.frame() %>%
  mutate(CenTaur_Z = Intercept + (SUVR * slope)) %>%
  add_column(.before = 1, ID =  ID)

print(subject_data)

output <- paste(ID,"_Centaur_spm12.csv",sep = "")
print(output)
# write the file 
write.csv(x = subject_data,file = output,
          row.names = F, quote = F,na = ".")

