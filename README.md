# NCBI_PowerTools_Docker
A Docker image with NCBI and other popular Bioinformatics tools.

## Examples of usage

1. Check BLAST version
  `docker run --rm -it ncbihackathons/bioinfo_power_tools blastn -version`

TODO: Please add other real-world examples.

## Want to help?
Please see the [TODO](TODO.md) file.

## Maintainer's notes

A `Makefile` is provided to conveniently maintain this docker image. In the
commands below, the value of `$X` represents the version of this docker image
to build.

* `make build VERSION=$X`: builds the docker image
* `make publish VERSION=$X`: publishes the image to Docker Hub. Assumes `docker
login` was run ahead of time.
* `make check`: performs a sanity check on the most recently built image

## Credits
* Ben Busby
* Ryan Connor
* Alex Efremov
* Christiam Camacho

### References

See also https://github.com/ncbi/docker.
