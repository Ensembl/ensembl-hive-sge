[![Build Status](https://travis-ci.org/Ensembl/ensembl-hive-sge.svg?branch=version/2.4)](https://travis-ci.org/Ensembl/ensembl-hive-sge)


SGE Meadow for eHive
====================

[https://travis-ci.org/Ensembl/ensembl-hive](eHive) is a system for running computation pipelines on distributed computing resources - clusters, farms or grids.
This repository is the implementation of eHive's _Meadow_ interface for the SGE job scheduler (Sun Grid Engine, now
known as Oracle Grid Engine).


Version numbering and compatibility
-----------------------------------

This repository is versioned the same way as eHive itself, and both
checkouts are expected to be on the same branch name to function properly.
* `master` is the development branch and follows eHive's `master`. We
  primarily maintain eHive, so both repos may sometimes go out of sync
  until we upgrade the SGE module too
* `version/2.4` is a stable branch that works with eHive's `version/2.4`
  branch. Both branches are _stable_ and _only_ receive bugfixes.

The module is continuously tested under SGE 8.1.8 thanks to
[https://github.com/robsyme/docker-sge](Robert Syme's Docker image of SGE
(built upon an initial release from Steve Moss)).


Contributors
------------

This module has been written in collaboration between [Lel
Eory](https://github.com/eorylel) (University of Edinburgh) and [Javier
Herrero](https://github.com/jherrero) (University College London) based on
the LSF.pm module.


Contact us
----------

eHive is maintained by the [http://www.ensembl.org/info/about/](Ensembl) project.
We (Ensembl) are only using Platform LSF to run our computation
pipelines, and can only test SGE on the Docker image indicated above.
Both Lel Eory and Javier Herrero have access to a "real" SGE cluster and
are better positioned to answer SGE-specific questions.

There is eHive users' mailing list for questions, suggestions, discussions and announcements.
To subscribe to it please visit (http://listserver.ebi.ac.uk/mailman/listinfo/ehive-users)

