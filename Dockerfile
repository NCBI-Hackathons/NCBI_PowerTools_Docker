FROM ncbi/blast-workbench:0.1 as base
FROM ubuntu:18.04

###############
# Copy BLAST tools from blast-workbench

COPY --from=base /root/edirect /root/edirect

RUN mkdir -p /magicblast/bin /magicblast/lib
COPY --from=base /magicblast/lib /magicblast/lib
COPY --from=base /magicblast/bin /magicblast/bin

RUN mkdir -p /blast/bin /blast/lib
COPY --from=base /blast/lib /blast/lib
COPY --from=base /blast/bin /blast/bin

###############
# Set up environment 
ENV PATH="/root/edirect:/blast/bin:/magicblast/bin:${PATH}"
ENV BLASTDB="/blast/blastdb:/blast/blastdb_custom"

RUN apt-get -y -m update && apt-get install -y curl wget parallel vmtouch git cpanminus libxml-simple-perl python3-minimal python-pip libwww-perl libnet-perl libjson-perl libgomp1 perl-doc liblmdb-dev && rm -rf /var/lib/apt/lists/* && cpanm HTML::Entities

## RUN pip install pybedtools

ENV NAMEH htslib
ENV NAME "samtools"

RUN git clone https://github.com/samtools/htslib.git 
####  && \
#cd ${NAMEH} && \
### git reset --hard ${SHA1H} && \
#make -j 4 && \
#cd .. && \
#cp ./${NAMEH}/tabix /usr/local/bin/ && \
#cp ./${NAMEH}/bgzip /usr/local/bin/ && \
#cp ./${NAMEH}/htsfile /usr/local/bin/ && \
#strip /usr/local/bin/tabix; true && \
#strip /usr/local/bin/bgzip; true && \
#strip /usr/local/bin/htsfile; true && 


RUN git clone https://github.com/samtools/samtools.git 
#### && \
#cd ${NAME} && \
## git reset --hard ${SHA1} && \
#make -j 4 && \
#cp ./${NAME} /usr/local/bin/ && \
#cd .. && \
#strip /usr/local/bin/${NAME}; true && \
#rm -rf ./${NAMEH}/ && \
#rm -rf ./${NAME}/ && \
#rm -rf ./${NAMEH}

# install SRA toolkit

RUN wget -q https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz
#RUN tar -xvzf 

RUN wget -q http://eddylab.org/software/hmmer/hmmer.tar.gz
#RUN tar -xvzf hmmer.tar.gz && \
#cd hmmer-3.2.1 && \
#./configure && \
#make && \
#make install

## Packages that still need to be installed

# Skesa

## Conda (PIA)

## this may be helpful: https://mfr.osf.io/render?url=https://osf.io/tf2mn/?action=download%26mode=render

CMD ["/bin/bash"]
