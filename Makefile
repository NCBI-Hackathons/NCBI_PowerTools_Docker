# Makefile for building this docker image
# Author: Christiam Camacho (camacho@ncbi.nlm.nih.gov)
# Created: Wed 05 Dec 2018 04:33:34 PM EST

SHELL=/bin/bash
.PHONY: all build publish check clean

USERNAME?=ncbihackathons
IMG=bioinfo_power_tools
VERSION?=0.1
NP=$(shell grep -c proc /proc/cpuinfo)

all: check

build:
	docker build --build-arg num_procs=${NP} -t ${USERNAME}/${IMG}:${VERSION} .
	docker tag ${USERNAME}/${IMG}:${VERSION} ${USERNAME}/${IMG}:latest

publish:
	docker push ${USERNAME}/${IMG}:${VERSION}
	docker push ${USERNAME}/${IMG}:latest

check:
	docker run --rm -dti ${USERNAME}/${IMG}:${VERSION} sleep infinity
	time docker exec `docker ps -lq` /bin/bash -c "printenv BLASTDB"
	time docker exec `docker ps -lq` blastn -version
	time docker exec `docker ps -lq` magicblast -version
	#time docker exec `docker ps -lq` installconfirm
	#time docker exec `docker ps -lq` efetch -db nucleotide -id u00001 -format fasta
	#time docker exec `docker ps -lq` get_species_taxids.sh -n squirrel
	#time docker exec `docker ps -lq` update_blastdb.pl --source gcp --showall
	#time docker exec `docker ps -lq` update_blastdb.pl --source gcp taxdb
	time docker exec `docker ps -lq` fastq-dump --stdout SRR390728 | head -n 8
	time docker exec `docker ps -lq` which bioawk
	time docker exec `docker ps -lq` which hmmstat
	docker rm -f `docker ps -lq`

clean:
	docker image rm ${USERNAME}/${IMG}:${VERSION} ${USERNAME}/${IMG}:latest
