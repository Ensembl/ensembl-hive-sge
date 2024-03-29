# Dockerfile to build SGE enabled container with extra packages needed to
# test eHive

# Cloned and updated version of the docker-sge container
FROM robsyme/docker-sge

# Install git
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get install -y git && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Clone the repos
RUN mkdir /repo \
    && git clone -b master https://github.com/Ensembl/ensembl-hive.git /repo/ensembl-hive \
    && git clone -b version/2.6 https://github.com/Ensembl/ensembl-hive-sge.git /repo/ensembl-hive-sge

# Install all the dependencies
RUN /repo/ensembl-hive/docker/setup_os.Ubuntu-16.04.sh \
    && /repo/ensembl-hive-sge/scripts/ensembl-hive-sge/setup_os.Ubuntu-16.04.sh \
    && /repo/ensembl-hive/docker/setup_cpan.Ubuntu-16.04.sh /repo/ensembl-hive /repo/ensembl-hive-sge

ENV EHIVE_ROOT_DIR "/repo/ensembl-hive/"
ENV PATH "/repo/ensembl-hive/scripts:$PATH"
ENV PERL5LIB "/repo/ensembl-hive/modules:/repo/ensembl-hive-sge/modules:$PERL5LIB"

# Since the environment is set for the root user, but root is not allowed
# to submit jobs, we need to login as sgeuser and preserve the environment
CMD ["/bin/login", "-p", "-f", "sgeuser"]
