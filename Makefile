DOCKER_BIN = docker
DOCKER_IMAGE = ubuntu-focal
TAR_BIN = tar

all: clean build

build:
	${DOCKER_BIN} build . --file Dockerfile --tag ${DOCKER_IMAGE}/lxd:latest
	${DOCKER_BIN} save ${DOCKER_IMAGE}/lxd:latest | ${TAR_BIN} --strip-components=1 --wildcards --to-command='${TAR_BIN} -xvf -' -xf - "*/layer.tar"

clean:
	${DOCKER_BIN} system prune -a -f
