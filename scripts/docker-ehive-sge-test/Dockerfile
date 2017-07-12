# Dockerfile to build SGE enabled container with extra packages needed to
# test eHive

# Cloned and updated version of the docker-sge container from robsyme
FROM robsyme/docker-sge

# install required extra software
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
    && apt-get install -y sqlite3 libdbd-sqlite3-perl libdbi-perl libcapture-tiny-perl libxml-simple-perl libdatetime-perl libjson-perl libtest-exception-perl perl-modules libtest-warn-perl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Location of the ensembl-hive and ensembl-hive-sge checkouts on the host
ARG HIVE_SGE_LOCATION
ARG EHIVE_LOCATION

# NOTE: We don't have access to $HIVE_SGE_LOCATION and $EHIVE_LOCATION
# at build-time, so we can't run cpanm. We hope all the dependencies are
# correctly installed with the above apt-get commands.

# Place symlinks for ensembl-hive and ensembl-hive-sge in sgeadmin's home directory
RUN ln -s "$HIVE_SGE_LOCATION" /home/sgeadmin/ensembl-hive-sge
RUN ln -s "$EHIVE_LOCATION" /home/sgeadmin/ensembl-hive

ENV EHIVE_ROOT_DIR "/home/sgeadmin/ensembl-hive"
ENV PATH "/home/sgeadmin/ensembl-hive/scripts:$PATH"
ENV PERL5LIB "/home/sgeadmin/ensembl-hive/modules:/home/sgeadmin/ensembl-hive-sge/modules:$PERL5LIB"
ENV EHIVE_TEST_PIPELINE_URLS='sqlite:////home/sgeadmin/'

# Since the environment is set for the root user, we need to add the "-p"
# option to transfer it to "sgeadmin" (only sgeadmin is allowed to submit
# jobs)
CMD ["/bin/login", "-p", "-f", "sgeadmin"]
