#!/usr/bin/env Rscript

library(magrittr)

data <- read.table("group_time-4070_space-anat_ref-infcereg_suvr.tsv",
                   header = T)


# thresh  right meta-roi 
thresh_meta_roi_right_regions <- c('ctx.rh.entorhinal', 'Right.Amygdala', 
'ctx.rh.fusiform', 'ctx.rh.inferiortemporal', 'ctx.rh.middletemporal', 
'ctx.rh.parahippocampal')

thresh_meta_roi_right <- data[, which(names(data) %in% thresh_meta_roi_right_regions)] %>%
rowMeans()



thresh_meta_roi_left_regions <- c ('ctx.lh.entorhinal', 'Left.Amygdala', 
                         'ctx.lh.fusiform', 'ctx.lh.inferiortemporal', 'ctx.lh.middletemporal', 
                         'ctx.lh.parahippocampal')

thresh_meta_roi_left <- data[, which(names(data) %in% thresh_meta_roi_left_regions)] %>%
  rowMeans()


# thresh_meta_roi_bilat. 

thresh_meta_roi_bilat_regions <-  c('ctx.lh.entorhinal', 'Left.Amygdala', 
        'ctx.lh.fusiform', 'ctx.lh.inferiortemporal', 'ctx.lh.middletemporal',
        'ctx.lh.parahippocampal', 'ctx.rh.entorhinal', 'Right.Amygdala', 
        'ctx.rh.fusiform', 'ctx.rh.inferiortemporal', 'ctx.rh.middletemporal', 
        'ctx.rh.parahippocampal')

thresh_meta_roi_bilat <- data[, which(names(data) %in% thresh_meta_roi_bilat_regions)] %>%
  rowMeans()

#thresh braak regions
thresh_braak1_regions <- c('ctx.lh.entorhinal', 'ctx.rh.entorhinal')

thresh_braak_1 <- data[, which(names(data) %in% thresh_braak1_regions)] %>%
  rowMeans()

# thresh braak 2 regions 

thresh_braak2_regions <- c('Left.Hippocampus', 'Right.Hippocampus')

thresh_braak_2 <- data[, which(names(data) %in% thresh_braak2_regions)] %>%
  rowMeans()

# Thresh_braak 3 regions 

thresh_braak3_regions <-  c('Left.Amygdala', 'Right.Amygdala', 
                           'ctx.lh.fusiform', 'ctx.rh.fusiform', 
                           'ctx.lh.parahippocampal', 'ctx.rh.parahippocampal',
                           'ctx.lh.lingual', 'ctx.rh.lingual')


thresh_braak_3 <- data[, which(names(data) %in% thresh_braak3_regions)] %>%
  rowMeans()


# Thresh_braak 4 regions 
thresh_braak4_regions <- c('ctx.lh.inferiortemporal', 'ctx.rh.inferiortemporal',
                   'ctx.lh.middletemporal', 'ctx.rh.middletemporal',
                   'ctx.lh.isthmuscingulate', 'ctx.rh.isthmuscingulate', 
                   'ctx.lh.caudalanteriorcingulate', 'ctx.rh.caudalanteriorcingulate', 
                   'ctx.lh.insula', 'ctx.rh.insula', 
                   'ctx.lh.posteriorcingulate', 'ctx.rh.posteriorcingulate', 
                   'ctx.lh.rostralanteriorcingulate', 'ctx.rh.rostralanteriorcingulate',
                   'ctx.lh.temporalpole', 'ctx.rh.temporalpole')


thresh_braak_4 <- data[, which(names(data) %in% thresh_braak4_regions)] %>%
  rowMeans()


# Thresh_braak 5 regions 
thresh_braak5_regions <- c('ctx.lh.lateraloccipital', 'ctx.rh.lateraloccipital', 
                  'ctx.lh.inferiorparietal', 'ctx.rh.inferiorparietal', 
                  'ctx.lh.superiortemporal', 'ctx.rh.superiortemporal', 
                  'ctx.lh.precuneus', 'ctx.rh.precuneus',
                  'ctx.lh.bankssts', 'ctx.rh.bankssts',
                  'ctx.lh.parsopercularis', 'ctx.rh.parsopercularis',
                  'ctx.lh.parsorbitalis', 'ctx.rh.parsorbitalis',
                  'ctx.lh.parstriangularis', 'ctx.lh.parstriangularis',
                  'ctx.lh.frontalpole', 'ctx.rh.frontalpole',
                  'ctx.lh.caudalmiddlefrontal', 'ctx.rh.caudalmiddlefrontal',
                  'ctx.lh.lateralorbitofrontal', 'ctx.rh.lateralorbitofrontal',
                  'ctx.lh.medialorbitofrontal', 'ctx.rh.medialorbitofrontal',
                  'ctx.lh.rostralmiddlefrontal', 'ctx.rh.rostralmiddlefrontal',
                  'ctx.lh.superiorfrontal', 'ctx.rh.superiorfrontal',
                  'ctx.lh.superiorparietal', 'ctx.rh.superiorparietal',
                  'ctx.lh.supramarginal', 'ctx.rh.supramarginal',
                  'ctx.lh.transversetemporal', 'ctx.rh.transversetemporal')


thresh_braak_5 <- data[, which(names(data) %in% thresh_braak5_regions)] %>%
  rowMeans()

#Braak VI is the last of our regions, and only comprises 5 regions

thresh_braak6_regions <-  c('ctx.lh.pericalcarine', 'ctx.rh.pericalcarine',
                   'ctx.lh.precuneus', 'ctx.rh.precuneus', 
                   'ctx.lh.paracentral', 'ctx.rh.paracentral',
                   'ctx.lh.postcentral', 'ctx.rh.postcentral',
                   'ctx.lh.precentral', 'ctx.rh.precentral')

thresh_braak_6 <- data[, which(names(data) %in% thresh_braak6_regions)] %>%
  rowMeans()


x <- data.frame(participant_id = data$participant_id,
           thresh_meta_roi_bilat,
           thresh_meta_roi_right,
           thresh_meta_roi_left,
           thresh_braak_1,
           thresh_braak_2,
           thresh_braak_3,
           thresh_braak_4,
           thresh_braak_5,
           thresh_braak_6)

print (format (x, justify = "left"), row.names = F, quote = F)


