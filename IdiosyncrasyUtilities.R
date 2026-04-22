#IdiosyncrasyUtilities.R
#Contains the functions required to analyze the idiosyncrasy data

library(mgcv)
library(ggplot2)

load.data <- function(csv.name, male.only = FALSE){
  df <- read.csv(csv.name)
  df[df == 999] <- NA
  df$sex <- factor(df$sex)
  df$comorbidity <- factor(df$comorbidity)
  df$drug <- factor(df$drug)
  df$group.2 <- factor(ifelse(df$group == 'TDC','TDC', 'ASC'))
  df$adhd <- factor(df$adhd)
  df$group.adhd <- factor(paste(as.character(df$group), ifelse(df$adhd == '1','+ ADHD', '- ADHD')))
  
  df$group <- factor(df$group)
  if (male.only){
    df <- df[df$sex == 1,]
  }
  return(df)
}

calc.var <- function(df.roi, var.type, diagnosis){
  corr.dist <- rdist::pdist(df.roi, metric = "correlation") #correlational distance matrix, n x n
  n <- nrow(df.roi)
  if (var.type == 'whole'){
    var.scores <- rowMeans(corr.dist) * n/(n-1) #accounting for correlation with self (0)
  } else{
    tdc.indices <- diagnosis == 'TDC'
    n.tdc <- sum(tdc.indices)
    
    asc.indices <- diagnosis == 'ASC-IA' | diagnosis == 'ASC-II'
    n.asc <- sum(asc.indices)
    
    if (var.type == 'within'){
      var.scores <- c(rowMeans(corr.dist[tdc.indices, tdc.indices]) * n.tdc/(n.tdc-1),
                      rowMeans(corr.dist[asc.indices, asc.indices]) * n.asc/(n.asc-1))
    } else if (var.type == 'tdc'){
      var.scores <- c(rowMeans(corr.dist[tdc.indices, tdc.indices]) * n.tdc/(n.tdc-1),
                      rowMeans(corr.dist[asc.indices, tdc.indices])) #no self correlation when comparing ASC to tdc
    }
  }
  return(var.scores)
}

calc.ratio <- function(variable, diagnosis, df){
  return(rev(table(df$group, df[,variable])[diagnosis,]))
}

all.ratios <- function(){
  
  groups <- c('TDC', 'ASC-IA', 'ASC-II')
  
}

chisq.p <- function(variable, unneeded = NA, df){
  freq.table <- table(df$group, df[,variable])
  if(!is.na(unneeded)){
    freq.table <- freq.table[rownames(freq.table) != unneeded,]
  }
  return(chisq.test(freq.table, simulate.p.value == TRUE)$p.value)
}

calc.mean <- function(variable, diagnosis, df){
  return(mean(df[,variable][df$group == diagnosis], na.rm = TRUE))
}

calc.sd <- function(variable, diagnosis, df){
  return(sd(df[,variable][df$group == diagnosis], na.rm = TRUE))
}

mean.sd <- function(variable, df){
  
  groups <- c('TDC', 'ASC-IA', 'ASC-II')
  
  return(as.vector(sapply(groups, 
                          function(x) return(c(calc.mean(variable, diagnosis = x, df.var.behav), 
                                               calc.sd(variable, diagnosis = x, df.var.behav))))))
  
  # return(c(calc.mean(variable, 'TDC', df),
  #          calc.sd(variable, 'TDC', df),
  #          calc.mean(variable, 'ASC-IA', df),
  #          calc.sd(variable, 'ASC-IA', df),
  #          calc.mean(variable, 'ASC-IA', df),
  #          calc.sd(variable, 'ASC-IA', df)))
}

anova.p <- function(variable, df){
  return(summary(aov(df[,variable] ~ df$group))[[1]][1,'Pr(>F)'])
}

# anova.summary <- function(variable, df){
#   return(summary(aov(df[,variable] ~ df$group))[[1]])#[1,'Pr(>F)'])
# }

tukey.vector <- function(variable, df){
  res <- TukeyHSD(aov(df[, variable] ~ df$group))[[1]]
  if (variable == 'ados'){
    return(c(rep(NA, 4), res['ASC-II-ASC-IA','p adj'], res['ASC-II-ASC-IA','diff']))
  } else{
    return(c(res['TDC-ASC-IA','p adj'], res['TDC-ASC-IA','diff'],
             res['TDC-ASC-II','p adj'], res['TDC-ASC-II','diff'],
             res['ASC-II-ASC-IA','p adj'], res['ASC-II-ASC-IA','diff']))
  }
}

fit.gam <- function(test, linear, male.only, current.data){
  if (test %in% linear){
    if (male.only){
      gam.formula <- as.formula('get(var.type) ~ get(test) + age + s(mean.fd)')
    } else{
      gam.formula <- as.formula('get(var.type) ~ get(test) + age + sex + s(mean.fd)')
    }
    return(gam(gam.formula, data = current.data, method = 'REML'))
  } else {
    if (male.only){
      gam.formula <- as.formula('get(var.type) ~ s(get(test)) + age + s(mean.fd)')
    } else{
      gam.formula <- as.formula('get(var.type) ~ s(get(test)) + age + sex + s(mean.fd)')
    }
    return(gam(gam.formula, data = current.data, method = 'REML'))
  }
}

get.tf <- function(test, linear, predictor, var.type, df, male.only){
  current.data <- df[!is.na(df[test]),]
  current.gam <- fit.gam(test = test, linear = linear, male.only = male.only, 
                         current.data = current.data)
  if (predictor == 'age' | predictor == 'sex1'){
    return(summary(current.gam)$p.t[predictor])
  } else if (predictor == 'mean.fd'){
    return(summary(current.gam)$s.table['s(mean.fd)', 'F'])
  } else if (predictor == 'behav'){
    if (test %in% linear){
      return(summary(current.gam)$p.t['get(test)'])
    } else{
      return(summary(current.gam)$s.table['s(get(test))', 'F'])
    }
  }
}

fit.scatterplot <- function(test, current.data, var.type, linear, var.labels, group.colours, current.gam){
  scatterplot <- current.data %>%
    ggplot(aes(x = get(test), y = get(var.type))) +
    geom_point(aes(color = group.2), size = 6) +
    scale_colour_manual(values=group.colours) +
    #geom_point(aes(y = predict.gam(current.gam)), shape = 18, size = 6)+
    xlab(test.labels[test]) + ylab(bquote(bold(VAR[.(var.labels[var.type])]))) +
    theme(axis.text.x=element_text(size=32, face='bold'), axis.text.y=element_text(size=32, face='bold'),
          axis.title.x=element_text(size=36, face='bold'), axis.title.y=element_text(size=36, face='bold'),
          legend.position = 'none')# + ylim(NA,0.75)
  
  if (test %in% linear){
    scatterplot <- scatterplot + geom_smooth(method = 'lm', colour = 'black',  aes(y = predict.gam(current.gam)))
  } else {
    scatterplot <- scatterplot + geom_smooth(method = mgcv::gam, aes(y = predict.gam(current.gam)), formula = y ~ s(x), colour = 'black')
  }
  
  return(scatterplot)
}
