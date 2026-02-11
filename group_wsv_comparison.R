library(lsr)
library(ggpubr)
library(stats)
library(dplyr)
library(broom)
library(sm)
library(fANCOVA)
library(mgcv)

var_score_type <- 'control_var_score'
parcellation_scheme <- 'Schaefer200+Tian+Suit'
beta_con_spmT <- 'spmT'
var_behav_data <- read.csv(paste('path of file',
                                 parcellation_scheme, '/', beta_con_spmT, '_0001/',
                                parcellation_scheme, '_', beta_con_spmT, '_0001_var_scores.csv',
                                 sep = ''))
var_behav_data[var_behav_data == 999] <- NA
var_behav_data$is_asc <- ifelse(var_behav_data$group == 'TDC','TDC', 'ASC')
var_behav_data <- var_behav_data[var_behav_data$sex == 1,]

# tdc_ia_data <- var_behav_data[1:61,]
# tdc_ii_data <- var_behav_data[c(1:33, 62:80),]
# ia_ii_data <- var_behav_data[34:80,]

tdc_ia_data <- var_behav_data[var_behav_data$group == "TDC" | var_behav_data$group == "ASC-IA",]
tdc_ii_data <- var_behav_data[var_behav_data$group == "TDC" | var_behav_data$group == "ASC-II",]
ia_ii_data <- var_behav_data[var_behav_data$group == "ASC-IA" | var_behav_data$group == "ASC-II",]


#are there group differences? (three groups)
three_ancova <- aov(whole_var_score ~ group + sex + age + mean_fd, data = var_behav_data)
summary(three_ancova)

#are group differences? (two groups)
two_ancova <- aov(whole_var_score ~ is_asc + sex + age + mean_fd, data = var_behav_data)
summary(two_ancova)
cohensD(var_behav_data$whole_var_score[1:33],var_behav_data$whole_var_score[34:80])

#are there differences between TDC and ASC-IA?
tdc_ia_ancova <- aov(whole_var_score ~ group + sex + age + mean_fd, data = tdc_ia_data)
summary(tdc_ia_ancova)
cohensD(var_behav_data$whole_var_score[1:33],var_behav_data$whole_var_score[34:61])

#are there differences between TDC and ASC-II?
tdc_ii_ancova <- aov(whole_var_score ~ group + sex + age + mean_fd, data = tdc_ii_data)
summary(tdc_ii_ancova)
cohensD(var_behav_data$whole_var_score[1:33],var_behav_data$whole_var_score[62:80])

#are there differences between ASC-IA and ASC-II?
ia_ii_ancova <- aov(whole_var_score ~ group + sex + age + mean_fd, data = ia_ii_data)
summary(ia_ii_ancova)
cohensD(var_behav_data$whole_var_score[34:61],var_behav_data$whole_var_score[62:80])

TukeyHSD(three_ancova, which = c('group'), conf_level = 0.95)
etaSquared(three_ancova)

library(car)
leveneTest(whole_var_score ~ group, data = var_behav_data)

ggscatter(
  var_behav_data, x = "mean_fd", y = "whole_var_score",
  color = "group", add = "reg.line"
)+
  stat_regline_equation(
    aes(label =  paste(..eq.label.., ..rr.label.., sep = "~~~~"), color = group)
  )

lm(formula = whole_var_score ~ group * mean_fd, data = var_behav_data)

# Fit the model, the covariate goes first
model <- lm(whole_var_score ~ group + sex + age + mean_fd, data = var_behav_data)
# Inspect the model diagnostic metrics
model.metrics <- augment(model)
shapiro.test(model.metrics$.resid)

test <- T.aov(var_behav_data[,4:5], var_behav_data$control_var_score, as.factor(var_behav_data$is_asc))
