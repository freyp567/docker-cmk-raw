# This file is used to manage local images
# depending of the current dir and branch.
# Branch 'master' leads to no tag (=latest),
# others to "local/[dirname]:[branchname]

# run 'make echo' to show the image name you're working on.

#REPO = local/$(shell basename `pwd`)
REPO = freyp567/omd-labs-ubuntu
TAG  = $(shell git rev-parse --abbrev-ref HEAD|grep -v master)

IMAGE=$(REPO):$(TAG)


.PHONY: build bash start stop

build:
	docker build -t $(IMAGE) .
	docker images | grep '$(REPO)'
start:
	docker run --name docker-omd -p 9080:80 -p 9022:22 -d $(IMAGE)
	docker images | grep '$(REPO)'
echo:
	echo $(IMAGE)
bash:
	docker run --rm -p 8080:80 -it $(IMAGE) /bin/bash

