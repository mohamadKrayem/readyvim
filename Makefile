IMAGE ?= dotfiles-test

.PHONY: docker-build docker-test docker-dev docker-clean

## Build the test image
docker-build:
	docker build -f docker/Dockerfile -t $(IMAGE) .

## Build then drop into a themed tmux session to try everything
docker-test: docker-build
	docker run -it --rm $(IMAGE)

## Like docker-test, but live-mount the repo so local edits show up instantly
docker-dev: docker-build
	docker run -it --rm -v "$(CURDIR)":/home/dev/personal/dotfiles $(IMAGE)

## Remove the test image
docker-clean:
	-docker rmi $(IMAGE)
