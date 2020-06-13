library(jsonlite)
library(dplyr)
library(data.table)


config <- read_json("config.json")
dir.create(file.path(config$datadir, "ready"))
dat <- read.table(file.path(config$datadir, "dl", "probeanno.tsv"), header=TRUE, stringsAsFactors=FALSE) %>% as_tibble()

dat$seqid2 <- gsub("-", "_", dat$seqid)
dat$filename <- file.path(config$datadir, "dl", paste0(dat$seqid, "_one.out.merged.h.tsv.gz"))
dat <- subset(dat, file.exists(filename))
table(file.exists(dat$filename))
table(duplicated(dat$seqid))
table(duplicated(dat$somaid))
table(duplicated(dat$target))
table(duplicated(dat$targetfull))

a <- tibble(
	note = paste0("name=", dat$targetfull, "; chr=", dat$chr, "; start=", dat$start, "; end=", dat$end, "; entrez=", dat$entrezgeneid, "; uniprot=", dat$uniprotid),
	id = paste0("prot-c-", dat$seqid2),
	sample.size = 997,
	sex =  "Males and females",
	category = "Continuous",
	subcategory = NA,
	unit = "SD",
	group_name = "public",
	build = "HG19/GRCh37",
	author = "Suhre K",
	year = 2019,
	population = "European",
	trait = dat$target,
	pmid = 28240269,
	ontology = "EFO_0007937",
	rawfile = dat$filename,
	filename = paste0(id, ".txt.gz"),
	outfile = file.path(config$datadir, "ready", filename),
	nsnp = 501428,
	delimiter = "space",
	header = TRUE,
	mr = 1,
	chr_col = 0,
	snp_col = 1,
	pos_col = 2,
	ea_col = 3,
	oa_col = 4,
	ncontrol_col = 5,
	beta_col = 6,
	se_col = 7,
	pval_col = 8
)

write.csv(a, file="input.csv")
write.csv(a, file=file.path(config$datadir, "ready", "input.csv"))

