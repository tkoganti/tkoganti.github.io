Rscript 01-run-EXTEND.R --input inputs/pbta-gene-expression-rsem-fpkm-collapsed.stranded.rds  --output output/TelomeraseScores_PTBAStranded_FPKM.txt 

Rscript 01-run-EXTEND.R --input inputs/pbta-gene-expression-rsem-fpkm-collapsed.polya.rds --output  output/TelomeraseScores_PTBAPolya_FPKM.txt

Rscript 01-run-EXTEND.R --input inputs/pnoc008_fpkm_matrix.rds --output output/TelomeraseScores_PNOC008_FPKM.txt



Rscript Comparing-Histology-versus-EXTENDScores_withPNOC008.R --output output/PBTA_stranded_histology_withPNOC008.pdf





