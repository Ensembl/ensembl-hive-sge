
SGE Meadow for eHive
====================

[![Build Status](https://travis-ci.org/Ensembl/ensembl-hive-sge.svg?branch=master)](https://travis-ci.org/Ensembl/ensembl-hive-sge)

[eHive](https://travis-ci.org/Ensembl/ensembl-hive) is a system for running computation pipelines on distributed computing resources - clusters, farms or grids.
This repository is the implementation of eHive's _Meadow_ interface for the SGE job scheduler (Sun Grid Engine, now
known as Oracle Grid Engine).


Version numbering and compatibility
-----------------------------------

This repository is versioned the same way as eHive itself, and both
checkouts are expected to be on the same branch name to function properly.
* `version/2.4` is a stable branch that works with eHive's `version/2.4`
  branch. Both branches are _stable_ and _only_ receive bugfixes.
* `master` is the development branch and follows eHive's `master`. We
  primarily maintain eHive, so both repos may sometimes go out of sync
  until we upgrade the SGE module too

The module is continuously tested under SGE 8.1.8 thanks to
[Robert Syme's Docker image of SGE](https://github.com/robsyme/docker-sge)
(built upon an initial release from [Steve Moss](https://github.com/gawbul)).


Testing the SGE meadow
----------------------

There are two solutions, dubbed "Quick start" and "Custom Docker". With the
former, the `robsyme/docker-sge` image will be downloaded and prepared for a
one-time use. With the latter, a prepared Docker image is built and stored
locally. It can then be used at will: this solution saves a lot of
resources (disk and time) if you are regularly testing the Meadow.

### Quick start

The scripts are located under `scripts/quick_start`
in the repo. They start a docker image and mount your own home
directory in order to share your existing ensembl-hive and ensembl-hive-sge
checkouts. You need to first edit the `HIVE_SGE_LOCATION` and `EHIVE_LOCATION`
variables in `setup_docker_and_login_sgeadmin.sh`

Assuming you are in your ensembl-hive-sge checkout:

```
./scripts/quick_start/start_docker.sh       # run as normal user on your machine. Will start the image as root and login as sgeadmin
source setup_environment.sh                 # run as "sgeadmin" on the image. Sets up $EHIVE_ROOT_DIR etc
prove -rv ensembl-hive-sge/t                # run as "sgeadmin" on the image. Uses sqlite
```

### Custom Docker image

The scripts are located under `scripts/custom-docker` in the repo. There is
a script to build a docker image, and one to run it. Both are simple wrappers
around `docker build` and `docker run`, and you might as well run `docker`
directly. The image will be named `docker-ehive-sge-test`.

You also need to define the `HIVE_SGE_LOCATION` and `EHIVE_LOCATION`
variables in `scripts/custom-docker/Dockerfile`.

```
./scripts/custom-docker/build_docker.sh     # run once as a normal user on your machine. Once built, the image will be reused
./scripts/custom-docker/start_docker.sh     # run as normal user on your machine. Will start the image as root and login as sgeadmin
source setup_environment.sh                 # run as "sgeadmin" on the image. Sets up $EHIVE_ROOT_DIR etc
prove -rv ensembl-hive-sge/t                # run as "sgeadmin" on the image. Uses sqlite
```

Contributors
------------

This module has been written in collaboration between [Lel
Eory](https://github.com/eorylel) (University of Edinburgh) and [Javier
Herrero](https://github.com/jherrero) (University College London) based on
the LSF.pm module.


Contact us
----------

eHive is maintained by the [Ensembl](http://www.ensembl.org/info/about/) project.
We (Ensembl) are only using Platform LSF to run our computation
pipelines, and can only test SGE on the Docker image indicated above.
Both Lel Eory and Javier Herrero have access to a "real" SGE cluster and
are better positioned to answer SGE-specific questions.

There is eHive users' mailing list for questions, suggestions, discussions and announcements.
To subscribe to it please visit [this link](http://listserver.ebi.ac.uk/mailman/listinfo/ehive-users)

