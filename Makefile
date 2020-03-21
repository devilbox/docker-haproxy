ifneq (,)
.error This Makefile requires GNU Make.
endif


# -------------------------------------------------------------------------------------------------
# Docker configuration
# -------------------------------------------------------------------------------------------------

DIR = .
FILE = Dockerfile
IMAGE = devilbox/haproxy
TAG = latest

.PHONY: help build rebuild test tag pull login push enter


# -------------------------------------------------------------------------------------------------
#  DEFAULT TARGET
# -------------------------------------------------------------------------------------------------

help:
	@echo "build               Build Docker image"
	@echo "rebuild             Rebuild Docker image without cache"
	@echo "tag [TAG=]          Tag Docker image"
	@echo "pull                Pull latest base image"
	@echo "login USER= PASS=   Login to Dockerhub"
	@echo "push [TAG=]         Push Docker image (and retag)"
	@echo "enter               Spawn bash and enter Docker image"


# -------------------------------------------------------------------------------------------------
#  GENERATE TARGETS
# -------------------------------------------------------------------------------------------------

build:
	docker build -t $(IMAGE) -f $(DIR)/$(FILE) $(DIR)

rebuild: pull
	docker build --no-cache -t $(IMAGE) -f $(DIR)/$(FILE) $(DIR)

test:
	./tests/test.sh $(IMAGE)

tag:
	docker tag $(IMAGE) $(IMAGE):$(TAG)

pull:
	docker pull $(shell grep FROM Dockerfile | sed 's/^FROM//g';)

login:
	yes | docker login --username $(USER) --password $(PASS)

push:
	@$(MAKE) tag TAG=$(TAG)
	docker push $(IMAGE):$(TAG)

enter:
	docker run --rm --name $(subst /,-,$(IMAGE)) -it --entrypoint=bash $(ARG) $(IMAGE)
