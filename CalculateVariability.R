#CalculateVariability.R
#This script is used to calculate whole-sample, within-sample, and TDC-reference variability


library(rdist)

df.var.behav <- read.csv('data/variability_behaviour.csv')
n <- nrow(df.var.behav) #num participants
n.tdc <- sum(df.var.behav$group == 'TDC')
n.asc <- sum(df.var.behav$group != 'TDC')

df.roi <- read.csv('data/roi_signal.csv', header = FALSE) #80 x 284, activity vectors for each participant, row order matches participant ID
corr.dist <- rdist::pdist(df.roi, metric = "correlation") #correlational distances

df.var <- data.frame(id = df.var.behav$id, group = df.var.behav$group, var.whole = rep(NA, n), var.within = rep(NA, n), var.tdc = rep(NA, n))

for (i in 1:n){
  #var.whole
  df.var[i, 'var.whole'] <- mean(corr.dist[i,]) * n/(n-1) #correlational distance with self is always 0, have to adjust
  
  #var.within and var.tdc
  if (df.var[i,'group'] == 'TDC'){
    df.var[i, 'var.within'] <- mean(corr.dist[i,df.var.behav$group == 'TDC'])*n.tdc/(n.tdc - 1) #compared to rest of TDC
    df.var[i, 'var.tdc'] <- mean(corr.dist[i,df.var.behav$group == 'TDC'])*n.tdc/(n.tdc - 1) #same, tdc is reference group
  } else{
    df.var[i, 'var.within'] <- mean(corr.dist[i,df.var.behav$group != 'TDC'])*n.asc/(n.asc - 1)
    df.var[i, 'var.tdc'] <- mean(corr.dist[i,df.var.behav$group == 'TDC']) #participant not part of reference group, no need to multiply
  }
}

#df.var results already included in variability_behaviour.csv, but can be exported separately if desired

write.csv(df.var, 'data/variability.csv', row.names = FALSE)