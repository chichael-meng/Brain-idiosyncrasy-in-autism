# Brain idiosyncrasy during biological-motion perception is amplified in autistic individuals with intellectual impairment

#### Michael Cheng<sup>1,2</sup>, Colin Hawco<sup>1,3,4</sup>, Daniel Yang<sup>5</sup>, Hsing-Chang Ni<sup>6,7</sup>, Chun-Hung Yeh<sup>6,8</sup>, Jung-Chi Chang<sup>9</sup>, En-Nien Tu<sup>10,11</sup>, Mei-Yun Hsu<sup>12</sup>, Yu-Yu Wu<sup>12</sup>, Tai-Li Chou<sup>13</sup>, Susan Shur-Fen Gau<sup>9</sup>, Hsiang-Yuan Lin<sup>1,2,4</sup>

**Please read our paper, and if you use this code, please cite our paper:**  
Journal of Neurodevelopmental Disorders (2026) - DOI: https://doi.org/10.1186/s11689-026-09683-3

## Affiliations
<sup>1. Institute of Medical Science, Faculty of Medicine, University of Toronto, Toronto, Ontario, Canada</sup>  
<sup>2. Azrieli Adult Neurodevelopmental Centre, Campbell Family Mental Health Research Institute, Centre for Addiction and Mental Health, Toronto, Ontario, Canada</sup>  
<sup>3. Campbell Family Mental Health Research Institute, Centre for Addiction and Mental Health, Toronto, Ontario, Canada</sup>  
<sup>4. Department of Psychiatry, Temerty Faculty of Medicine, University of Toronto, Toronto, Ontario, Canada</sup>  
<sup>5. Independent Scholar (with George Washington University, USA while this study was being conducted)</sup>  
<sup>6. Department of Psychiatry, Chang Gung Memorial Hospital at Linkou, Taoyuan, Taiwan</sup>  
<sup>7. College of Medicine, Chang Gung University, Taoyuan, Taiwan</sup>  
<sup>8. Department of Medical Imaging and Radiological Sciences, Chang Gung University, Taoyuan, Taiwan</sup>  
<sup>9. Department of Psychiatry, National Taiwan University Hospital and College of Medicine, Taipei, Taiwan</sup>  
<sup>10. Department of Psychiatry, University of Oxford, Oxford, United Kingdom</sup>  
<sup>11. Department of Psychiatry, Keelung Chang Gung Memorial Hospital, Keelung, Taiwan</sup>  
<sup>12. YuNing Clinic, Taipei, Taiwan</sup>  
<sup>13. Department of Psychology, National Taiwan University, Taipei, Taiwan</sup>

## Abstract
#### Background:
Neuroimaging research in autism spectrum condition (ASC) often overlooks brain idiosyncrasy by focusing on group averages and frequently excludes individuals with co-occurring intellectual impairment (II). 
#### Methods: 
We investigated functional MRI correlates of passive biological motion (BM) perception, comparing typically developing controls (TDC; n=33), autistic individuals without II (intellectually able; ASC-IA; n=28), and autistic individuals with II (ASC-II; n=19; defined by IQ or adaptive function <85). 
#### Results: 
While standard group-average analyses revealed the expected BM-sensitive regions (e.g., bilateral posterior superior temporal sulci, cuneus) in the TDC and ASC-IA groups, the ASC-II group showed no consistent group-level activation pattern and exhibited greater activation in the right intraparietal sulcus compared to the ASC-IA group. Using a correlational distance-based metric, we quantified brain idiosyncrasy (“whole-sample brain variability”, Variability<sub>Whole</sub>), representing the deviance of an individual's activation pattern from others. Brain activity in the ASC-II group was significantly more idiosyncratic than the ASC-IA and TDC groups. Furthermore, VariabilityWhole showed significant transdiagnostic correlations with multiple cognitive and behavioural domains relevant to autism, including social difficulties, repetitive behaviours, non-verbal IQ, executive function, sensory hyper/hyposensitivity, ADHD symptoms, and adaptive function. 
#### Conclusions: 
Key limitations include the cross-sectional design and the use of a passive viewing task without a concurrent behavioral measure to directly link brain findings to task performance. These findings highlight substantial brain heterogeneity within the autism spectrum, particularly in the understudied ASC-II subgroup, and suggest that individual differences in brain processing patterns, rather than solely group-average differences, are critically linked to clinical and cognitive phenotypes.

## Repo Contents
### data
**roi_signal.csv** is an 80 * 284 matrix describing the average BOLD signal from each of the 80 participants across 284 parcels. A whole-brain parcellation was constructed from the Schaefer200 cortical, Melbourne subcortex, and SUIT cerebellum atlases.  
**variability_behaviour.csv** contains the variability/idiosyncrasy scores calculated from the ROI signals as well as the results of several neuropsychological tests.
**group_diff** contains csv files with the results from **GroupVarComparison.Rmd** (ANCOVA tests for group differences in variability). These csv files are used to label the significance values in the raincloud plots.

### CalculateVariability.R
Calculate whole-sample (Variability<sub>Whole</sub>), within-sample (Variability<sub>Within</sub>), and TDC-reference (Variability<sub>TDC</sub>) variability scores.

### Demographics.Rmd
Assess differences in demographic (e.g. age, sex, etc.) and clinical (e.g. NVIQ, ADOS, etc.) characteristics across groups (chi-square, ANOVA). This script was used to generate Table 1.

### GroupVarComparison.Rmd
Calculate and assess the significance of group differences in Variability. This code was used to generate Table S3. The results of this script are exported as csv files which are used to label the significance statistics in the raincloud plots.

### IdiosyncrasyUtilities.R
Various custom functions used for analysis.

### RaincloudPlots.Rmd
Visually represent group differences in Variability with raincloud plots. This code was used to generate Fig. 3, S1, and S2 using the results from **GroupVarComparison.Rmd**, which are included in **data/group_diff**
![Figure 3](https://github.com/chichael-meng/Images/blob/main/fig%203.png)

### ScatterplotGAM.Rmd
Evaluate brain-behaviour correlations and graphically represent them with scatterplots. This code was used to generate Tables S2 and S4 and Figures 4, and S3-S7.
![Figure 4](https://github.com/chichael-meng/Images/blob/main/fig%204.png)

___

Please direct any code-related enquiries to first-author MC (michaelcheng.cheng@mail.utoronto.ca) and general enquiries to senior author HYL (hsiang-yuan.lin@camh.ca). The raw imaging data is available upon reasonable request.  

**Thank you very much for your interest in our work! :D**
