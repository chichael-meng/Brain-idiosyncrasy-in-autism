library(devtools)
var_scores <- read.csv('path to file')
var_scores[var_scores == 999] <- NA

#chi-square
for (i in c(3, 14, 15)){
  current_table <- table(var_scores$group, var_scores[,i])
  print(colnames(var_scores[i]))
  print(chisq.test(current_table, simulate.p.value = TRUE))
  #post-hoc
  for (j in 1:3){
    post_hoc_table <- current_table[-j,]
    print(row.names(post_hoc_table))
    print(chisq.test(post_hoc_table, simulate.p.value = TRUE))
  }
}
#anova
for (i in c(4:5,7:13)){
  model <- aov(var_scores[,i] ~ var_scores$group)
  
  #mean and sd
  df_basic <- data.frame(tdc_mean = numeric(), tdc_sd = numeric(), 
                         ia_mean = numeric(), ia_sd = numeric(), 
                         ii_mean = numeric(), ii_sd = numeric())
  
  df_basic[1,"tdc_mean"] <- mean(var_scores[,i][var_scores$group == "TDC"], na.rm = TRUE)
  df_basic[1,"ia_mean"] <- mean(var_scores[,i][var_scores$group == "ASC-IA"], na.rm = TRUE)
  df_basic[1,"ii_mean"] <- mean(var_scores[,i][var_scores$group == "ASC-II"], na.rm = TRUE)
  
  df_basic[1,"tdc_sd"] <- sd(var_scores[,i][var_scores$group == "TDC"], na.rm = TRUE)
  df_basic[1,"ia_sd"] <- sd(var_scores[,i][var_scores$group == "ASC-IA"], na.rm = TRUE)
  df_basic[1,"ii_sd"] <- sd(var_scores[,i][var_scores$group == "ASC-II"], na.rm = TRUE)
  
  
  print(colnames(var_scores)[i])
  print(df_basic)
  print(summary(model))
  print(TukeyHSD(model))
}
#ados anova
var_scores_asc <- var_scores[var_scores$group != 'TDC',]
ados_model <- aov(var_scores_asc$ados ~ var_scores_asc$group)
print('ados')
print(summary(ados_model))
print(TukeyHSD(ados_model))
