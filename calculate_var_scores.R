library('dplyr')

parcellation_names <- list('Schaefer200_cortical',
                          'Schaefer200_plus_HO',
                          'Schaefer200+Tian+Suit',
                          "shen268")
beta_con_spmT <- list('beta', 
                     'con',
                     'spmT')

for (name in parcellation_names){
  for (stat in beta_con_spmT){
    ROISignal_data <- read.csv(paste('path to file', 
                                     name, '/',
                                     stat, '_0001/',
                                     name, '_', stat, '_0001_ROISignals.csv',
                                     sep = ''), 
                               header = FALSE)
    corr_dist_matrix <- rdist::pdist(ROISignal_data, metric = "correlation")
    cov_data <- read.csv('path to file')
    
    cov_data$row_num <- seq_len(nrow(cov_data))
    
    
    within_var_score <- rep(999, nrow(cov_data))
    for (i in 1:nrow(cov_data)){
      if (cov_data$group[i] == 'TDC'){
        within_var_score[i] <- mean(corr_dist_matrix[cov_data$row_num[i],1:33])*33/32
      } else {
        within_var_score[i] <- mean(corr_dist_matrix[cov_data$row_num[i],34:80])*47/46
      }
    }
    
    control_var_score <- rep(999, nrow(cov_data))
    for (i in 1:nrow(cov_data)){
      if (cov_data$group[i] == 'TDC'){
        control_var_score[i] <- mean(corr_dist_matrix[cov_data$row_num[i],1:33])*33/32
      } else {
        control_var_score[i] <- mean(corr_dist_matrix[cov_data$row_num[i],1:33])
      }
      
    }
    
    #rowMeans includes the participant's correlational distance with themselves (0)
    #multiply by 80 (n including participant) and divide by 79 (n not including participant)
    var_scores <- tibble(cov_data[,1:15], rowMeans(corr_dist_matrix)*80/79, within_var_score, control_var_score) %>% rename(whole_var_score = 16)
    
    write.csv(var_scores, paste('path to file',
                                name, '/', stat, '_0001/',
                                name, '_', stat, '_0001_var_scores.csv',
                                sep = ''),
              row.names = FALSE)

    write.csv(var_scores, paste('path to file',
                                name, '_', stat, '_0001_var_scores.csv',
                                sep = ''),
              row.names = FALSE)
  }
}
