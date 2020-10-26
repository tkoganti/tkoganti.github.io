library('ggpubr')
stringsAsFactors=FALSE
library(grid)
library(forcats) ### for fct_reorder()
library(optparse)
library(cowplot)
library(tidyverse)
############################################################### Combining Histology with EXTEND Scores (Figure 3) ###############################################################################


root_dir <- rprojroot::find_root(rprojroot::has_dir(".git"))

A = file.path("inputs", "pbta-histologies.tsv")   ### Variable representing clinical data

B = file.path("output", "TelomeraseScores_PTBAStranded_FPKM.txt")   ### Variable representing Telomerase activity-prediction for Stranded_FPKM data

C = file.path("output", "TelomeraseScores_PNOC008_FPKM.txt") ## Telomerase activity-prediction for PNOC008_FPKM data

D = file.path("inputs", "pnoc008_hist_manuallygeneratedtill_pnoc008-15.tsv")   ### Variable representing clinical data

# set up the command line options
option_list <- list(
  make_option(c("-o", "--output"), type = "character",
              help = "Plot output (.pdf)")
)


# parse the command line arguments - this becomes a list
# where each element is named by the long flag option
opt <- parse_args(OptionParser(option_list = option_list))

PBTA_EXTEND_HistologyCompPlot <- opt$output



PTBA_Histology = readr::read_tsv(A, guess_max = 10000)    ## Reading the clinical data

colnames(PTBA_Histology)[colnames(PTBA_Histology)=="Kids_First_Biospecimen_ID"]='SampleID'   ## Renaming "Kids_First_Biospecimen_ID" as SampleID for comparison purpose

PTBA_GE_Standard_TMScores = read.table(B,sep='\t',head=T)  ## Reading Stranded FPKM telomerase scores
PTBA_GE_Standard_Histology = merge(PTBA_Histology,PTBA_GE_Standard_TMScores,by='SampleID')   ### Merging Clinical data with the Telomerase scores

pnoc008_TMScores = read.table(C,sep='\t',head=T)  ## Reading PNOC008 FPKM telomerase scores
pnoc008_TMScores <- pnoc008_TMScores %>% select(SampleID, NormEXTENDScores)
pnoc008_TMScores$SampleID <- str_replace(pnoc008_TMScores$SampleID, 'PNOC008.', 'PNOC008-')

PNOC008_histology <- read.table(D,sep='\t',head=T)  ## Reading PNOC008 histology
PNOC008_histology<- PNOC008_histology %>% select(cohort_participant_id, short_histology,	broad_histology, cohort)
colnames(PNOC008_histology)[colnames(PNOC008_histology)=="cohort_participant_id"]='SampleID' ## Renaming cohort_aprticipant_id with SampleID for merging

pnoc008_TMScores_and_Histology <- merge(PNOC008_histology,pnoc008_TMScores,by='SampleID') ## PNOC008 samples
																																													## with histology  and TM scores

Stranded_Histology = PTBA_GE_Standard_Histology
# If there are any "Other" samples, remove them
if (any(Stranded_Histology$short_histology == "Other")) {
  Stranded_Histology = Stranded_Histology[-which(Stranded_Histology$short_histology == "Other"),]   ### Removing the tumors with catagory labelled as "Others"
}


Frequency = data.frame(table(Stranded_Histology$short_histology))  ### Counting the number of cases for all histologies to avoid less number further
colnames(Frequency)=c('Variables','Freq') ## Renaming column headers
Frequency = Frequency[which(Frequency$Freq == 1),]  ## Only retaining of freq=1

Stranded_Histology = Stranded_Histology[-which(Stranded_Histology$short_histology %in% Frequency$Variables),]     ### Removing the tumors with only one case in histologies
Stranded_Histology = Stranded_Histology  %>% select(SampleID, short_histology,  NormEXTENDScores, broad_histology, cohort)

# Adding PNOC008 samples
Stranded_Histology <- rbind(Stranded_Histology,pnoc008_TMScores_and_Histology)

print(head(Stranded_Histology))
print(tail(Stranded_Histology))




pdf(PBTA_EXTEND_HistologyCompPlot)

## Globally set the theme in one step, so it gets applied to both plots
theme_set(theme_classic() +
          theme(plot.title = element_text(size=10, face="bold"),axis.text.x=element_text(angle=50,size=6,vjust=1,hjust=1),axis.text.y=element_text(size=7), axis.title.x = element_text(size=0), axis.title.y = element_text(size=8),
          legend.position = "top",
          legend.key.size= unit(0.3,"cm"),
          legend.key.width = unit(0.3,"cm"),
          legend.title = element_text(size=7),
          legend.text =element_text(size=6)
        )
)

#P1 = ggplot(Stranded_Histology, aes(x=fct_reorder(short_histology,NormEXTENDScores,.desc =TRUE),y=NormEXTENDScores))+geom_boxplot(size= 0.1,notch=FALSE,outlier.size = 0,outlier.shape=NA,fill="pink",alpha=0.5)+ geom_jitter(alpha= 0.5,shape=16, cex=0.3)+  ylab("EXTEND Scores")+ ggtitle("Tumor Short Histology")
P1 = ggplot(Stranded_Histology, aes(x=fct_reorder(short_histology,NormEXTENDScores,.desc =TRUE),y=NormEXTENDScores))+  ylab("EXTEND Scores")+ ggtitle("Tumor Short Histology") + geom_point(aes(col=cohort, shape=cohort), position="jitter", size = 0.7) + geom_boxplot(size= 0.1,notch=FALSE,outlier.size = 0,outlier.shape=NA,fill="pink",alpha=0.5)
#P2 = ggplot(Stranded_Histology, aes(x=fct_reorder(broad_histology,NormEXTENDScores,.desc =TRUE),y=NormEXTENDScores))+geom_boxplot(size= 0.1,notch=FALSE,outlier.size = 0,outlier.shape=NA,fill="pink",alpha=0.5)+ geom_jitter(alpha=0.5,shape=16, cex=0.3)+ ylab("EXTEND Scores")+ ggtitle("Tumor Broad Histology")
P2 = ggplot(Stranded_Histology, aes(x=fct_reorder(broad_histology,NormEXTENDScores,.desc =TRUE),y=NormEXTENDScores))+ ylab("EXTEND Scores")+ ggtitle("Tumor Broad Histology") + geom_point(aes(col=cohort, shape=cohort), position="jitter", size = 0.7) + geom_boxplot(size= 0.1,notch=FALSE,outlier.size = 0,outlier.shape=NA,fill="pink",alpha=0.5)


plot_grid(P1,P2, nrow = 2,labels = "AUTO", label_size = 12, scale=c(0.95,0.95),  align = "v")

dev.off()
