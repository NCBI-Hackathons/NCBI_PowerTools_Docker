FROM ncbi/workbench:0.1 as base
FROM ubuntu:18.04

LABEL Description="NCBI Hackathons Bioinformatics tools" \
      Vendor="NCBI/NLM/NIH" \
      URL="https://github.com/NCBI-Hackathons/NCBI_PowerTools_Docker"

###############
# Copy NCBI tools from ncbi/workbench

COPY --from=base /root/edirect /root/edirect

RUN mkdir -p /magicblast/bin /magicblast/lib
COPY --from=base /magicblast/lib /magicblast/lib
COPY --from=base /magicblast/bin /magicblast/bin

RUN mkdir -p /blast/bin /blast/lib
COPY --from=base /blast/lib /blast/lib
COPY --from=base /blast/bin /blast/bin

RUN mkdir -p /blast/bin /blast/lib
COPY --from=base /blast/lib /blast/lib
COPY --from=base /blast/bin /blast/bin

RUN mkdir -p /usr/local/ncbi/sra-toolkit
COPY --from=base /usr/local/ncbi/sra-toolkit /usr/local/ncbi/sra-toolkit

###############
# Set up environment 
ENV PATH="/root/edirect:/blast/bin:/magicblast/bin:/usr/local/ncbi/sra-toolkit:${PATH}"
ENV BLASTDB="/blast/blastdb:/blast/blastdb_custom"

RUN apt-get -y -m update --fix-missing && apt-get install -y \
        curl wget zip gawk bzip2 autoconf cmake rsync \
        parallel bison flex vmtouch git cpanminus fuse \
        zlib1g-dev libbz2-dev liblzma-dev libcurl4-openssl-dev \
        libidn11 libgomp1 liblmdb-dev libxml2-utils \
        python3-minimal python-pip python3-flask python3-pip \
        python-pyasn1 python-pyasn1-modules \
        libxml-simple-perl libwww-perl libnet-perl libjson-perl perl-doc && \
        rm -rf /var/lib/apt/lists/* && cpanm HTML::Entities


###############
# Bioawk
RUN git clone https://github.com/lh3/bioawk.git && \
    cd bioawk && \
    make && \
    mv bioawk /usr/bin

RUN pip3 install -q snakemake psutil lxml HTSeq dedupe pybedtools && \
    pip install -q gsutil

###############
# Hisat2
RUN wget -q https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.9.2/hisat2-2.1.0-64-ngs.2.9.2.zip && \
    unzip -qq hisat2-2.1.0-64-ngs.2.9.2.zip && \
    mv ./hisat2 /opt && \
    echo -e "export PATH=/opt/hisat2:\$PATH\nexport HISAT2_HOME=/opt/hisat2" > /etc/profile.d/hisat2.sh && \
    chmod 755 /etc/profile.d/hisat2.sh && \
    rm hisat2-2.1.0-64-ngs.2.9.2.zip
ENV PATH="/opt/hisat2:${PATH}"
ENV HISAT2_HOME=/opt/hisat2

###############
# HTS Lib
RUN wget -q https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2 && \
    tar xjf htslib-1.9.tar.bz2 && \
    rm htslib-1.9.tar.bz2 && \
    cd htslib-1.9 && \
    ./configure >/dev/null && \
    make --quiet && \
    make --quiet install && \
    cd .. && \
    rm -rf ./htslib-1.9
#ENV NAMEH htslib
#ENV NAME "samtools"

###############
# SAM tools
RUN wget -q https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
    tar xjf samtools-1.9.tar.bz2 && \
    rm samtools-1.9.tar.bz2 && \
    cd samtools-1.9 && \
    ./configure --without-curses >/dev/null && \
    make --quiet && \
    make --quiet install && \
    cd .. && \
    rm -rf ./samtools-1.9

###############
# BCF Tools
RUN wget -q https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2 && \
    tar xjf bcftools-1.9.tar.bz2 && \
    rm bcftools-1.9.tar.bz2 && \
    cd bcftools-1.9 && \
    ./configure --without-curses >/dev/null && \
    make --quiet && \
    make --quiet install && \
    cd .. && \
    rm -rf ./bcftools-1.9

###############
# Skesa and aux NCBI tools
#RUN gsutil cp gs://ncbi_hackathon_aux_tools/* /usr/bin && \
#    chmod 755 /usr/bin/skesa && \
#    chmod 755 /usr/bin/guidedassembler_graph && \
#    chmod 755 /usr/bin/compute-coverage

###############
# anaconda for python 2.7
# Important - anaconda at the end of PATH to avoid breaking R installation
RUN wget -q https://repo.anaconda.com/archive/Anaconda2-5.3.1-Linux-x86_64.sh && \
    chmod 755 Anaconda2-5.3.1-Linux-x86_64.sh && \
    ./Anaconda2-5.3.1-Linux-x86_64.sh -b -p /opt/anaconda2 && \
    rm ./Anaconda2-5.3.1-Linux-x86_64.sh && \
    echo -e "export PATH=\$PATH:/opt/anaconda2/bin\nexport JAVA_HOME=/opt/anaconda2" > /etc/profile.d/anaconda2.sh && \
    chmod 755 /etc/profile.d/anaconda2.sh
ENV PATH="/opt/anaconda2/bin:${PATH}"

###############
# GATK, BWA, minimap2, bowtie2, HMMER, DESeq2
RUN /opt/anaconda2/bin/conda config --add channels defaults && \
    /opt/anaconda2/bin/conda config --add channels bioconda && \
    /opt/anaconda2/bin/conda config --add channels conda-forge && \
    /opt/anaconda2/bin/conda install -yq gatk bwa minimap2 bowtie2 hmmer bioconductor-deseq2
RUN wget -q "https://software.broadinstitute.org/gatk/download/auth?package=GATK-archive&version=3.8-1-0-gf15c1c3ef" -O GenomeAnalysisTK-3.8-1-0-gf15c1c3ef.tar.bz2 && \
    tar xjf GenomeAnalysisTK-3.8-1-0-gf15c1c3ef.tar.bz2 && \
    rm GenomeAnalysisTK-3.8-1-0-gf15c1c3ef.tar.bz2 && \
    mv ./GenomeAnalysisTK-3.8-1-0-gf15c1c3ef /opt && \
    /opt/anaconda2/bin/gatk3-register /opt/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar

###############
# HTS JDK 
# depends on Java installation (needs 1.8). Anaconda comes with the correct Java.
ENV JAVA_HOME=/opt/anaconda2
RUN git clone https://github.com/samtools/htsjdk.git && \
    cd htsjdk && \
    ./gradlew -q build -x test && \
    cd ./build/libs && \
    mkdir /opt/htsjdk && \
    mv htsjdk-*-SNAPSHOT.jar /opt/htsjdk && \
    ln -s $(ls -l /opt/htsjdk/htsjdk-*-SNAPSHOT.jar | awk '{print $9}') /opt/htsjdk/htsjdk.jar && \
    cd ../../.. && \
    rm -rf htsjdk

###############
# Picard tools
RUN wget -q https://github.com/broadinstitute/picard/releases/download/2.18.17/picard.jar && \
    wget -q https://github.com/broadinstitute/picard/releases/download/2.18.17/picardcloud.jar && \
    mkdir /opt/picard && \
    chmod 755 /opt/picard && \
    mv picard.jar picardcloud.jar /opt/picard && \
    echo -e "export PICARD=/opt/picard/picard.jar\nexport PICARDCLOUD=/opt/picard/picardcloud.jar\nexport PATH=/opt/picard:\$PATH" > /etc/profile.d/picard.sh && \
    echo -e "java -jar \$PICARD \$*" > /opt/picard/picard && \
    echo -e "java -jar \$PICARDCLOUD \$*" > /opt/picard/picardcloud && \
    chmod 755 /opt/picard/picard && \
    chmod 755 /opt/picard/picardcloud && \
    chmod 755 /etc/profile.d/picard.sh
ENV PICARD=/opt/picard/picard.jar
ENV PICARDCLOUD=/opt/picard/picardcloud.jar
ENV PATH="/opt/picard:${PATH}"

###############
# STAR 2.6.0
RUN wget -q https://github.com/alexdobin/STAR/archive/2.6.0a.tar.gz && \
    tar -xzf 2.6.0a.tar.gz && \
    rm 2.6.0a.tar.gz && \
    mv ./STAR-2.6.0a /opt && \
    ln -s /opt/STAR-2.6.0a/bin/Linux_x86_64_static/STAR /opt/STAR-2.6.0a/bin/STAR && \
    ln -s /opt/STAR-2.6.0a/bin/Linux_x86_64_static/STARlong /opt/STAR-2.6.0a/bin/STARlong && \
    echo -e "export PATH=/opt/STAR-2.6.0a/bin:\$PATH" > /etc/profile.d/STAR.sh && \
    chmod 755 /etc/profile.d/STAR.sh
ENV PATH="/opt/START-2.6.0a/bin:${PATH}"

###############
# abyss
# FIXME: not found
#RUN apt-get -qqy install abyss && \
#    echo -e "export PATH=/usr/lib/abyss:\$PATH" > /etc/profile.d/abyss.sh && \
#    chmod 755 /etc/profile.d/abyss.sh

###############
# plink-ng
RUN wget -q http://s3.amazonaws.com/plink2-assets/plink2_linux_x86_64_20181028.zip && \
    unzip -qq plink2_linux_x86_64_20181028.zip && \
    rm plink2_linux_x86_64_20181028.zip && \
    mv ./plink2 /usr/bin

###############
# cufflinks
RUN wget -q http://cole-trapnell-lab.github.io/cufflinks/assets/downloads/cufflinks-2.2.1.Linux_x86_64.tar.gz && \
    tar -xzf cufflinks-2.2.1.Linux_x86_64.tar.gz && \
    rm cufflinks-2.2.1.Linux_x86_64.tar.gz && \
    mv ./cufflinks-2.2.1.Linux_x86_64 /opt && \
    echo -e "export PATH=/opt/cufflinks-2.2.1.Linux_x86_64:\$PATH" > /etc/profile.d/cufflinks.sh && \
    chmod 755 /etc/profile.d/cufflinks.sh
ENV PATH="/opt/cufflinks-2.2.1.Linux_x86_64:${PATH}"

###############
# Cytoscape
#ENV INSTALL4J_JAVA_HOME=/opt/anaconda2
#RUN wget -q https://github.com/cytoscape/cytoscape/releases/download/3.7.0/Cytoscape_3_7_0_unix.sh && \
#    chmod 755 ./Cytoscape_3_7_0_unix.sh && \
#    ./Cytoscape_3_7_0_unix.sh -q && \
#    rm ./Cytoscape_3_7_0_unix.sh && \
#    echo -e "export PATH=/opt/Cytoscape_v3.7.0:\$PATH" > /etc/profile.d/Cytoscape.sh && \
#    chmod 755 /etc/profile.d/Cytoscape.sh

###############
# Zerbino velvet
RUN wget -q https://www.ebi.ac.uk/~zerbino/velvet/velvet_1.2.10.tgz && \
    tar -xzf velvet_1.2.10.tgz && \
    rm velvet_1.2.10.tgz && \
    cd velvet_1.2.10 && \
    make --quiet && \
    cp velvetg velveth /usr/bin && \
    cd .. && \
    rm -rf velvet_1.2.10

###############
# TopHat
RUN wget -q http://ccb.jhu.edu/software/tophat/downloads/tophat-2.1.1.Linux_x86_64.tar.gz && \
    tar -xzf tophat-2.1.1.Linux_x86_64.tar.gz && \
    rm tophat-2.1.1.Linux_x86_64.tar.gz && \
    mv ./tophat-2.1.1.Linux_x86_64 /opt && \
    echo -e "export PATH=/opt/tophat-2.1.1.Linux_x86_64:\$PATH" > /etc/profile.d/tophat.sh && \
    chmod 755 /etc/profile.d/tophat.sh
ENV PATH="/opt/tophat-2.1.1.Linux_x86_64:${PATH}"

###############
# FastQC
RUN wget -q https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.8.zip && \
    unzip -qq fastqc_v0.11.8.zip && \
    rm fastqc_v0.11.8.zip && \
    chmod 755 ./FastQC/fastqc && \
    mv ./FastQC /opt && \
    echo -e "export PATH=/opt/FastQC:\$PATH" > /etc/profile.d/FastQC.sh && \
    chmod 755 /etc/profile.d/FastQC.sh
ENV PATH="/opt/FastQC:${PATH}"

###############
# MrBayes
RUN wget -q https://github.com/NBISweden/MrBayes/raw/v3.2.6/mrbayes-3.2.6.tar.gz && \
    tar -xzf mrbayes-3.2.6.tar.gz && \
    rm ./mrbayes-3.2.6.tar.gz && \
    cd ./mrbayes-3.2.6/src && \
    autoconf && \
    ./configure --with-beagle=no >/dev/null && \
    make --quiet && \
    make --quiet install

###############
# Clustal Omega
RUN wget -q http://www.clustal.org/omega/clustalo-1.2.4-Ubuntu-x86_64 && \
    chmod 755 ./clustalo-1.2.4-Ubuntu-x86_64 && \
    mv ./clustalo-1.2.4-Ubuntu-x86_64 /usr/bin && \
    ln -s /usr/bin/clustalo-1.2.4-Ubuntu-x86_64 /usr/bin/clustalo 

###############
# Trinity RNA Seq
RUN wget -q https://github.com/trinityrnaseq/trinityrnaseq/archive/Trinity-v2.8.4.tar.gz && \
    tar -xzf Trinity-v2.8.4.tar.gz && \
    cd ./trinityrnaseq-Trinity-v2.8.4 && \
    make --quiet && \
    make --quiet install && \
    ln -s /usr/local/bin/trinityrnaseq-Trinity-v2.8.4/Trinity /usr/local/bin/Trinity && \
    echo -e "export TRINITY_HOME=/usr/local/bin" > /etc/profile.d/trinityrnaseq.sh && \
    chmod 755 /etc/profile.d/trinityrnaseq.sh
ENV PATH="/usr/local/bin:${PATH}"


#RUN wget -q http://eddylab.org/software/hmmer/hmmer.tar.gz
#RUN tar -xvzf hmmer.tar.gz && \
#cd hmmer-3.2.1 && \
#./configure && \
#make && \
#make install

## Packages that still need to be installed

## this may be helpful: https://mfr.osf.io/render?url=https://osf.io/tf2mn/?action=download%26mode=render

CMD ["/bin/bash"]
