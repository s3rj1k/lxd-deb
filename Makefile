DOCKER_IMAGE = ubuntu-focal

BASENAME_BIN ?= basename
DOCKER_BIN ?= docker
FIND_BIN ?= find
TAR_BIN ?= tar

all: clean build

build:
	${DOCKER_BIN} build . --file Dockerfile --tag ${DOCKER_IMAGE}/lxd:latest
	${DOCKER_BIN} save ${DOCKER_IMAGE}/lxd:latest | ${TAR_BIN} --strip-components=1 --wildcards --to-command='${TAR_BIN} -xvf -' -xf - "*/layer.tar"

clean:
	${DOCKER_BIN} system prune -a -f

.PHONY: print-env
print-env:
	LXD_PACKAGE_DEB=$(shell ${FIND_BIN} . -maxdepth 1 -name 'lxd*.deb' -type f -exec ${BASENAME_BIN} {} \;)
