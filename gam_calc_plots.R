
library(ggplot2)
library(mgcv)
library(dplyr)
library(stats)
library(tidyverse)

var_score_types <- c("whole_var_score", "within_var_score", "control_var_score")
var_score_labels <- c("Whole", 'Within', 'TDC')
# var_score_types <- c("control_var_score")
# var_score_labels <- c('TDC')
parcellation_schemes <- c("Schaefer200+Tian+Suit")
# psych_tests <- c('ADOS-2 CSS')
psych_tests <- c('ADOS-2 CSS', 'NVIQ','VABS-ABC', 'SRS Total', 'RBS-R Total', 'SSP Total', 'BRIEF-GEC', 'SNAP-IV Total')
parametric <- c('ados', 'snap_t', 'vabs_total', 'brief_gec')


group_colours <- c('TDC' = 'blue', 'ASC' = 'red')

for (scheme in parcellation_schemes){
  var_behav_data <- read.csv(paste("path to file",
                                   scheme, "/spmT_0001/", scheme, "_spmT_0001_var_scores.csv",
                                   sep = ""))
  var_behav_data[var_behav_data == 999] <- NA
  var_behav_data$sex <- factor(var_behav_data$sex)
  #remove females
  #var_behav_data <- var_behav_data[var_behav_data$sex == 1,]
  
  #var_behav_data$sex <- scale(var_behav_data$sex, scale = FALSE)
  #var_behav_data$drug <- scale(var_behav_data$drug, scale = FALSE)
  var_behav_data$is_asc <- factor(ifelse(var_behav_data$group == "TDC", "TDC", "ASC"))
  
  for (i in 1:length(var_score_types)){
    type <- var_score_types[i]
    sig_stats <- data.frame(behav_uncorr = rep(NA, length(psych_tests)), 
                           age_uncorr = rep(NA, length(psych_tests)),
                           sex_uncorr = rep(NA, length(psych_tests)),
                           fd_uncorr = rep(NA, length(psych_tests))) #store p values from gams
    rownames(sig_stats) <- psych_tests
    
    for (j in 1:length(psych_tests)){ 
      #define gam
      col <- colnames(var_behav_data)[5 + j] #column name of psych test in var_behav_data
      current_data <- var_behav_data[!is.na(var_behav_data[col]),] #remove participants with missing values for current psych test
      if (col %in% parametric){
        current_gam <- gam(get(type) ~ get(col) + age + sex + s(mean_fd), data = current_data, method = 'REML')
        sig_stats[j, 'tf'] <- summary(current_gam)$p.t['get(col)']
        sig_stats[j, 'behav_uncorr'] <- summary(current_gam)$p.pv['get(col)']
      } else {
        current_gam <- gam(get(type) ~ s(get(col)) + age + sex + s(mean_fd), data = current_data, method = 'REML')
        sig_stats[j, 'tf'] <- summary(current_gam)$s.table['s(get(col))', 'F']
        sig_stats[j, 'behav_uncorr'] <- summary(current_gam)$s.table['s(get(col))', 'p-value']
      }
      sig_stats[j, 'age_uncorr'] <- summary(current_gam)$p.pv['age']
      sig_stats[j, 'sex_uncorr'] <- summary(current_gam)$p.pv['sex1']
      sig_stats[j, 'fd_uncorr'] <- summary(current_gam)$s.table['s(mean_fd)', 'p-value']
      sig_stats[j, 'r2_adj'] <- summary(current_gam)$r.sq
      
      #show gam results
      print(type)
      print(col)
      print(summary(current_gam))
      plot.gam(current_gam, pages = 1)
      
      #make scatterplot
      scatterplot <- current_data %>%
        ggplot(aes(x = get(col), y = get(type))) +
        geom_point(aes(color = is_asc), size = 6) +
        scale_colour_manual(values=group_colours) +
        #geom_point(aes(y = predict.gam(current_gam)), shape = 18, size = 6)+
        xlab(psych_tests[j]) + ylab(bquote(bold(VAR[.(var_score_labels[i])]))) +
        theme(axis.text.x=element_text(size=32, face='bold'), axis.text.y=element_text(size=32, face='bold'),
              axis.title.x=element_text(size=36, face='bold'), axis.title.y=element_text(size=36, face='bold'),
              legend.position = 'none')# + ylim(NA,0.75)

      if (col %in% parametric){
        scatterplot <- scatterplot + geom_smooth(method = 'lm', colour = 'black',  aes(y = predict.gam(current_gam)))
      } else {
        scatterplot <- scatterplot + geom_smooth(method = mgcv::gam, aes(y = predict.gam(current_gam)), formula = y ~ s(x), colour = 'black')
      }


      tiff_name <- paste("path to file",
                        type, "/", col, "_gam_", type, ".tiff", sep = '')
      print(scatterplot)
      # tiff(file=tiff_name, width=4096, height=2160, res=300)
      # print(scatterplot)
      # dev.off()
    }
    
    var_num <- length(colnames(sig_stats)) - 2
    orig_vars <- colnames(sig_stats)
    for (k in 1:var_num){
      sig_stats <- add_column(sig_stats, 'placeholder' = p.adjust(sig_stats[,orig_vars[k]], method = 'BH'), .after = orig_vars[k])
      corr_name <- paste(str_split_1(orig_vars[k], '_')[1], '_corr', sep = '')
      colnames(sig_stats)[colnames(sig_stats) == 'placeholder'] = corr_name
      sig_stats <- add_column(sig_stats, 'placeholder' = sig_stats[,corr_name] <= 0.05, .after = corr_name)
      colnames(sig_stats)[colnames(sig_stats) == 'placeholder'] = paste(str_split_1(orig_vars[k], '_')[1], '_sig', sep = '')
    }
    csv_name <- paste('path to file', 
                      str_split_1(type, '_')[1], '.csv', sep = '')
    #write.csv(sig_stats, csv_name)
  }
}