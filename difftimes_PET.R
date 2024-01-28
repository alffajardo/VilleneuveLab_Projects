#!/usr/bin/Rscript

library(magrittr)
library(dplyr)
library(lubridate)

# read the pet demographic information
pet_demographics <- read.csv("prevent-ad/Nov2023/PAD_PET_demog_Nov2023.csv")


# read amyloid and tau datasets

amy <- read_delim("prevent-ad/Nov2023/PAD_PET_NAV_suvr_space-anat_ref-cerebellumCortex_time-4070_Nov2023.tsv") 

tau <- read_delim("prevent-ad/Nov2023/PAD_PET_TAU_suvr_space-anat_ref-infcereg_time-4070_Nov2023.tsv")

# full join of the amyloid and tau datasets

pet <- full_join(amy,tau) %>%
  full_join(select(pet_demographics,Primary_key_PET,Date_PET,age_PET)) %>%
  group_by(PSCID,Tracer_PET) %>%
  mutate(n_timepoints = n()) %>%
  ungroup ()



# transform the date variable to an actual date
pet$Date_PET <- as_date(pet$Date_PET)


# Calculate the time diffenrece in PET for amyloid and tau

pet_splitted <- pet %>%
filter(n_timepoints == "2",!is.na(PSCID)) %>% # include only those participants with two visits
  group_by(Tracer_PET,Visit_label_PET) %>%
  group_split() # generate de list

# calculate the time differences acrros sessions, per subject. 

# this is the number of years between BL and FU
amy_years <- difftime(pet_splitted[[2]]$Date_PET,
                      pet_splitted[[1]]$Date_PET) %>%
  time_length("years")

amy_years <- data.frame( PSCID = pet_splitted[[1]]$PSCID, years = amy_years)

amy_years <- amy_years %>%
            select(1:2) %>%
           mutate(full_id = paste("sub-PADMTL",PSCID, sep = '')) %>%
          select(full_id, years) %>%
          arrange(full_id)
# now we write a txt file

write.table(x = amy_years, "NAV_years.txt", sep = " ", 
            col.names = F,
            row.names = F,
            quote = F)


ta