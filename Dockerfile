FROM ubuntu:18.04

USER root
WORKDIR /root/

RUN apt-get -y -m update && apt-get install -y build-essential wget libidn11 libnet-perl liblist-moreutils-perl perl-doc libnet-ssleay-perl libcam-pdf-perl cpanminus libgomp1

RUN cpanm IO::Socket::SSL \
LWP::Protocol::https
Config::Simple
Readonly
HTML::Entities
List::MoreUtils

RUN wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/LATEST/ncbi-blast-2.7.1+-src.tar.gz
RUN tar xvf ncbi-blast-2.7.1+-src.tar.gz
WORKDIR /root/ncbi-blast-2.7.1+-src/c++
RUN ./configure --with-optimization --with-dll --with-experimental=Int8GI --with-flat-makefile --prefix=/blast
WORKDIR /root/ncbi-blast-2.7.1+-src/c++/ReleaseMT/build
RUN make -f Makefile.flat blastdb_aliastool.exe blastdbcheck.exe blastdbcmd.exe blast_formatter.exe blastn.exe blastp.exe blastx.exe convert2blastmask.exe deltablast.exe dustmasker.exe makeblastdb.exe makembindex.exe makeprofiledb.exe psiblast.exe rpsblast.exe rpstblastn.exe segmasker.exe tblastn.exe tblastx.exe windowmasker.exe

RUN mkdir -p /blast/bin /blast/lib
COPY --from=blastbuild /root/ncbi-blast-2.7.1+-src/c++/ReleaseMT/bin /blast/bin
COPY --from=blastbuild /root/ncbi-blast-2.7.1+-src/c++/ReleaseMT/lib /blast/lib


## Install all this stuff:
Python3
Conda
Pip
SRA Toolkit
MagicBLAST
BedTools
Samtools
Skesa
EDirect
Hmmer

## this may be helpful: https://mfr.osf.io/render?url=https://osf.io/tf2mn/?action=download%26mode=render

WORKDIR /blast/blastdb
ENV BLASTDB /blast/blastdb
ENV PATH="/blast/bin:${PATH}"

CMD ["/bin/bash"]
