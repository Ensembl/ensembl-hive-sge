# Dockerfile to build SGE enabled container with extra packages needed to
# test eHive

# Cloned and updated version of the docker-sge container from robsyme
FROM robsyme/docker-sge

# maintained by Ensembl
MAINTAINER Ensembl

# run everything as root to start with
USER root

# install required extra software
RUN apt-get update -y
RUN apt-get install -y sqlite3 libdbd-sqlite3-perl libdbi-perl libcapture-tiny-perl libxml-simple-perl libdatetime-perl libjson-perl libtest-exception-perl perl-modules libtest-warn-perl
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Location of the ensembl-hive and ensembl-hive-sge checkouts on the host
ARG HIVE_SGE_LOCATION
ARG EHIVE_LOCATION

# Place symlinks for ensembl-hive and ensembl-hive-sge in sgeadmin's home directory
RUN ln -s "$HIVE_SGE_LOCATION" /home/sgeadmin/ensembl-hive-sge
RUN ln -s "$EHIVE_LOCATION" /home/sgeadmin/ensembl-hive
RUN ln -s ensembl-hive-sge/scripts/custom-docker/setup_environment.sh /home/sgeadmin/

# start my_init on execution and pass bash to runit
ENTRYPOINT ["/sbin/my_init", "--"]
CMD ["/bin/bash"]
