FROM christiam/edirect as edirect
FROM christiam/magicblast as magicblast
FROM christiam/blast

RUN apt-get -y -m update && apt-get install -y curl wget zlib1g-dev vmtouch git cpanminus libxml-simple-perl python3-minimal python-pip libwww-perl libnet-perl && rm -rf /var/lib/apt/lists/* && cpanm HTML::Entities

COPY --from=edirect /usr/local/ncbi/edirect /root/edirect
RUN mkdir /magicblast/
RUN mkdir /magicblast/bin /magicblast/lib
COPY --from=magicblast /blast/bin/magicblast /magicblast/bin/magicblast.REAL
#RUN bash magicblast-wrapper.sh /magicblast/bin/magicblast
#RUN chmod +x /magicblast/bin/magicblast
#COPY --from=magicblast /blast/lib /magicblast/lib

ENV PATH "/root/edirect:/blast/bin:/magicblast/bin:${PATH}"
ENV BLASTDB "/blast/blastdb:/blast/blastdb_custom"

# this doesnt work yet:

## RUN pip install pybedtools

ENV NAMEH htslib
ENV NAME "samtools"

RUN git clone https://github.com/samtools/htslib.git 
## cd htslib && \
## git reset --hard && \
## make -j 4 
#cd .. && \
#cp ./${NAMEH}/tabix /usr/local/bin/ && \
#cp ./${NAMEH}/bgzip /usr/local/bin/ && \
#cp ./${NAMEH}/htsfile /usr/local/bin/ && \
#strip /usr/local/bin/tabix; true && \
#strip /usr/local/bin/bgzip; true && \
#strip /usr/local/bin/htsfile; true && 


RUN git clone https://github.com/samtools/samtools.git
#cd samtools && \
## make -j 4 
#cp ./${NAME} /usr/local/bin/ && \
#cd .. && \
#strip /usr/local/bin/${NAME}; true && \
#rm -rf ./${NAMEH}/ && \
#rm -rf ./${NAME}/ && \
#rm -rf ./${NAMEH}

# install SRA toolkit

RUN wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz
#RUN tar -xvzf 

RUN wget http://eddylab.org/software/hmmer/hmmer.tar.gz
RUN tar -xvzf hmmer.tar.gz && \
cd hmmer-3.2.1 && \
./configure && \
make && \
make install

## Packages that still need to be installed

# Skesa

## Conda (PIA)

## this may be helpful: https://mfr.osf.io/render?url=https://osf.io/tf2mn/?action=download%26mode=render

CMD ["/bin/bash"]
