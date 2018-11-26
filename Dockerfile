FROM christiam/edirect as edirect
FROM christiam/magicblast as magicblast
FROM christiam/blast

COPY --from=edirect /usr/local/ncbi/edirect /root/edirect
RUN apt-get -y -m update && apt-get install -y curl vmtouch cpanminus libxml-simple-perl libwww-perl libnet-perl && rm -rf /var/lib/apt/lists/* && cpanm HTML::Entities

RUN mkdir -p /magicblast/bin /magicblast/lib
COPY --from=magicblast /blast/bin/magicblast /magicblast/bin/magicblast.REAL
COPY ./magicblast-wrapper.sh /magicblast/bin/magicblast
RUN chmod +x /magicblast/bin/magicblast
COPY --from=magicblast /blast/lib /magicblast/lib

ENV PATH "/root/edirect:/blast/bin:/magicblast/bin:${PATH}"
ENV BLASTDB "/blast/blastdb:/blast/blastdb_custom"

RUN pip install pybedtools

ENV NAMEH htslib
ENV ENV NAME "samtools"

RUN git clone https://github.com/samtools/htslib.git && \
cd ${NAMEH} && \
## git reset --hard ${SHA1H} && \
make -j 4 && \
cd .. && \
cp ./${NAMEH}/tabix /usr/local/bin/ && \
cp ./${NAMEH}/bgzip /usr/local/bin/ && \
cp ./${NAMEH}/htsfile /usr/local/bin/ && \
strip /usr/local/bin/tabix; true && \
strip /usr/local/bin/bgzip; true && \
strip /usr/local/bin/htsfile; true && 


RUN git clone https://github.com/samtools/samtools.git && \
cd ${NAME} && \
## git reset --hard ${SHA1} && \
make -j 4 && \
cp ./${NAME} /usr/local/bin/ && \
cd .. && \
strip /usr/local/bin/${NAME}; true && \
rm -rf ./${NAMEH}/ && \
rm -rf ./${NAME}/ && \
rm -rf ./${NAMEH}

RUN wget ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/edirect.tar.gz
RUN tar -xvzf edirect.tar.gz
RUN bash ./edirect/setup.sh
ENV PATH="/edirect/bin:${PATH}"

## this will need to be updated

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
