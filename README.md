
SGE Meadow for eHive
====================

> [!IMPORTANT]  
> As per eHive version 2.7.0, all the meadows other than `SLURM` and `Local` are deprecated and not supported anymore.
> This repository should remain in sync with eHive's `version/2.6`, as we do not plan to apply any change to it.
> The `main` branch is expected to go out of sync over time as we apply changes to eHive.
>
> Please, do not hesitate to contact us, should this be a problem.

[![Build Status](https://travis-ci.org/Ensembl/ensembl-hive-sge.svg?branch=version/2.6)](https://travis-ci.org/Ensembl/ensembl-hive-sge)

[eHive](https://travis-ci.org/Ensembl/ensembl-hive) is a system for running computation pipelines on distributed computing resources - clusters, farms or grids.
This repository is the implementation of eHive's _Meadow_ interface for the SGE job scheduler (Sun Grid Engine, now
known as Oracle Grid Engine).


Version numbering and compatibility
-----------------------------------

This repository is versioned the same way as eHive itself, and both
checkouts are expected to be on the same branch name to function properly.
* `version/2.4`, `version/2.5`, etc. are stable branchs that work with eHive's
  branches of the same name. These branches are _stable_ and _only_ receive bugfixes.
* `main` is the development branch and follows eHive's `main`. We
  primarily maintain eHive, so both repos may sometimes go out of sync
  until we upgrade the SGE module too

The module is continuously tested under SGE 8.1.9 using a [Docker image of
SGE](https://hub.docker.com/r/robsyme/docker-sge) (contributions from
[Matthieu Muffato](https://github.com/muffato), [Robert
Syme's](https://github.com/robsyme) and [Steve
Moss'](https://github.com/gawbul)).


Testing the SGE meadow
----------------------

You can use the Docker image
[ensemblorg/ensembl-hive-sge](https://hub.docker.com/r/ensemblorg/ensembl-hive-sge),
which contains all the dependencies and checkouts.

```
docker run -it ensemblorg/ensembl-hive-sge  # run as normal user on your machine. Will start the image as sgeuser
prove -rv ensembl-hive-sge/t                # run as "sgeuser" on the image. Uses sqlite
```

To test your own version of the code, you can use
`scripts/ensembl-hive-sge/start_test_docker.sh`.
The scriptwill start a new ``ensemblorg/ensembl-hive-sge`` container with
your own copies of ensembl-hive and ensembl-hive-sge mounted.

```
scripts/ensembl-hive-sge/start_test_docker.sh /path/to/your/ensembl-hive /path/to/your/ensembl-hive-sge name_of_docker_image

```

The last argument can be skipped and defaults to `ensemblorg/ensembl-hive-sge`.

Contributors
------------

This module has been written in collaboration between [Lel
Eory](https://github.com/eorylel) (University of Edinburgh) and [Javier
Herrero](https://github.com/jherrero) (University College London) based on
the LSF.pm module. The Docker layer has been added by [Matthieu
Muffato](https://github.com/muffato) (EMBL-EBI).


Contact us
----------

eHive is maintained by the [Ensembl](http://www.ensembl.org/info/about/) project.
We (Ensembl) are only using SLURM to run our computation
pipelines, and can only test SGE on the Docker image indicated above.
Both Lel Eory and Javier Herrero have access to a "real" SGE cluster and
are better positioned to answer SGE-specific questions.

There is eHive users' mailing list for questions, suggestions, discussions and announcements.
To subscribe to it please visit [this link](http://listserver.ebi.ac.uk/mailman/listinfo/ehive-users)

