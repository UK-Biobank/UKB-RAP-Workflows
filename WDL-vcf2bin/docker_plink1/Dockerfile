FROM ubuntu:focal

RUN apt-get update && apt-get install --no-install-recommends -y \
 libcurl4-openssl-dev && \
 rm -rf /var/lib/apt/lists/* && apt-get autoclean

COPY plink /usr/local/bin
COPY bcftools /usr/local/bin

RUN chmod a+x /usr/local/bin/plink
RUN chmod a+x /usr/local/bin/bcftools

RUN mkdir /data
WORKDIR /data
