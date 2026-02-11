library(ggplot2)
library(ggrain)
library(ggpubr)
library(forcats)

var_scores <- read.csv('path to file')

group_colours <- c('TDC' = 'blue', 'ASC-IA' = '#ff781f', 'ASC-II' = '#c50171')

raincloud_plot <- var_scores %>% 
  mutate(group = fct_relevel(group, 'ASC-II', 'ASC-IA', 'TDC')) %>% 
  ggplot(aes(x=group, y=control_var_score, colour = group, fill = group)) +
  geom_rain(point.args = list(size = 3.5)) +
  stat_compare_means(comparisons = list(c("TDC", "ASC-IA"), c("TDC","ASC-II"), c("ASC-IA", "ASC-II")),
                     symnum.args = list(cutpoints = c(0, 0.001, 0.01, 0.05, Inf), symbols = c("***", "**", "*", "NS.")),
                     size = 8, face = "bold") +
  theme(text = element_text(face = "bold"))+
  ylab(bquote(bold(VAR[TDC])))+labs(fill = 'Group')+
  theme(axis.text.x=element_text(size=23, face='bold'), axis.text.y=element_text(size=23, face='bold'),
        axis.title.x=element_text(size=27, face='bold'), axis.title.y=element_blank(),
        legend.position = 'none') +
  scale_colour_manual(values=group_colours) + 
  scale_fill_manual(values= alpha(group_colours, 0.5)) + 
  coord_flip()
#+ggtitle('Schaefer200+Tian+Suit TDC Sample Variability')
print(raincloud_plot)

tiff(file='path to file',width=2400, height=1600, res=300)
raincloud_plot
dev.off()
