DOCKER_BIN = docker
DOCKER_IMAGE = ubuntu-focal

all: clean build

build:
	${DOCKER_BIN} build . --file Dockerfile --tag ${DOCKER_IMAGE}/lxd:latest
	${DOCKER_BIN} save ${DOCKER_IMAGE}/lxd:latest | tar --strip-components=1 --wildcards --to-command='tar -xvf -' -xf - "*/layer.tar"

clean:
	${DOCKER_BIN} system prune -a -f
