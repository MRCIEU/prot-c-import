library(parallel)
library(GwasDataImport)
library(dplyr)
library(data.table)

a <- read.csv("input.csv", stringsAsFactors=FALSE) %>% as_tibble()
mclapply(1:nrow(a), function(i)
{
	message(i)
	infile <- a$rawfile[i]
	outfile <- a$outfile[i]

	a <- fread(infile, header=TRUE)
	a$se <- a$beta / a$z
	b <- dplyr::select(a, chr="hm_chrom", snp="hm_rsid", pos="hm_pos", ea="hm_effect_allele", oa="hm_other_allele", n="neff", beta="hm_beta", se="se", pval="p-value") %>% subset(!is.na(pos))
	b <- liftover_gwas(b)
	gz <- gzfile(outfile, "w")
	write.table(b, gz, row=F, col=T, qu=F)
	close(gz)
}, mc.cores=16)

