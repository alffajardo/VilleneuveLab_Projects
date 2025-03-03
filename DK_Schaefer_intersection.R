#!/usr/bin/env Rscript 


library(neurobase)
library(magrittr)
library(fslr)
library(tidyverse)

`%notin%` <- Negate(`%in%`)

anat <- readNIfTI2("orig.nii.gz")

dk <- readNIfTI2("aparc+aseg.nii.gz")

schaefer <- readNIfTI2("Schaefer2018_200Parcels_7Networks.nii.gz")

#ortho2(x = anat, dk)
#ortho2(x = anat, schaefer)

amyloid_index_labels <- c(1003,1012,1014,1018,1019,1020,1027,1028,1032,1008,1025,
                          1029,1031,1002,1023,1010,1026,2003,2012,2014,2018,
                          2019,2020,2027,2028,2032,2008,2025,2029,2031,2002,2023,
                          2010,2026,1015,1030,2015,2030,2009,1009)


temporal_meta_roi_index_labels <- c(1006,18,96,1007,1009,1015,1016,2006,
                                    54,97,2007,2009,2015,2016 )
  
  
  
  
## create the amyloid index mask 

tau_mask <- dk
amy_mask <- dk


amy_mask[amy_mask %notin% amyloid_index_labels] <- 0

amy_mask[amy_mask !=0] <- 1

ortho2(anat,amy_mask)


tau_mask[tau_mask %notin% temporal_meta_roi_index_labels] <- 0

tau_mask[tau_mask !=0] <- 1

ortho2(anat, tau_mask, col.y =  "blue")

# now calculate the intersection

schaefer_amy_mask <- schaefer
schaefer_amy_mask[amy_mask == 0] <- 0

schaefer_tau_mask <- schaefer

schaefer_tau_mask[tau_mask == 0] <- 0

ortho2(anat, schaefer_amy_mask, col.y = "pink")
ortho2(anat,schaefer_tau_mask, col.y = "green")

schaefer_amy_labels <- schaefer_amy_mask[amy_mask ==1] %>% 
  unique() %>%
  sort() %>%
  data.frame(index = .) %>% 
  filter(index  %notin% c(0,2,41,1000,2000)) %>%
  unlist()


schaefer[schaefer %notin% schaefer_amy_labels ] <- 0 

  




data.frame(schaefer_amy_labels) %>%
  write.table(x =. ,file = "Schaefer_ab_labels.txt",quote = F,
              row.names = F,sep = "",col.names = F)

schaefer_tau_labels <- schaefer_tau_mask[tau_mask ==1] %>% 
  unique() %>%
  sort() %>%
  data.frame(index = .) %>% 
  filter(index  %notin% c(0,2,41,1000,2000)) %>%
  unlist()

data.frame(schaefer_tau_labels) %>%
  write.table(x =. ,file = "Schaefer_tau_labels.txt",quote = F,
              row.names = F,sep = "",col.names = F)

