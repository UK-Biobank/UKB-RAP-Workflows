FROM ubuntu:focal

RUN apt-get update && apt-get install --no-install-recommends -y \
 libcurl4-openssl-dev && \
 rm -rf /var/lib/apt/lists/* && apt-get autoclean

COPY bcftools /usr/local/bin
RUN chmod a+x /usr/local/bin/bcftools

COPY bcftools_vanilla /usr/local/bin
RUN chmod a+x /usr/local/bin/bcftools_vanilla

RUN mkdir /data
COPY GRCh38_full_analysis_set_plus_decoy_hla.fa /data
COPY GRCh38_full_analysis_set_plus_decoy_hla.fa.fai /data
COPY GRCh38_full_analysis_set_plus_decoy_hla.dict /data

WORKDIR /data
