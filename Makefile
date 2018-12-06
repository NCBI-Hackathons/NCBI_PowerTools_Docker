# Makefile for building this docker image
# Author: Christiam Camacho (camacho@ncbi.nlm.nih.gov)
# Created: Wed 05 Dec 2018 04:33:34 PM EST

SHELL=/bin/bash
.PHONY: all build check clean

USERNAME?=christiam
IMG=ncbi-power-tools

all: check

build:
	docker build -t ${USERNAME}/${IMG} .

check: build
	time docker run --rm ${USERNAME}/${IMG} /bin/bash -c "printenv BLASTDB"
	time docker run --rm ${USERNAME}/${IMG} blastn -version
	time docker run --rm ${USERNAME}/${IMG} magicblast -version
	time docker run --rm ${USERNAME}/${IMG} installconfirm
	time docker run --rm ${USERNAME}/${IMG} efetch -db nucleotide -id u00001 -format fasta
	time docker run --rm ${USERNAME}/${IMG} get_species_taxids.sh -n squirrel
	time docker run --rm ${USERNAME}/${IMG} update_blastdb.pl --source gcp --showall
	time docker run --rm ${USERNAME}/${IMG} update_blastdb.pl --source gcp taxdb

clean:
	docker image rm ${USERNAME}/${IMG}
