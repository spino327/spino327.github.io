SHELL=/usr/bin/env sh

##################################################
# Verbose & Log
#################################################
QUIET:=@
ifdef VERBOSE
	QUIET:=
endif

##################################################
# Rules
##################################################
.PHONY: help
help:
	@echo "Personal site"
	@echo ""
	@echo "Do make [rule], where rule may be one of:"
	@echo "  - build: build the site."
	@echo "  - run: locally runs the site."
	@echo "  - clean: cleans jekyll project."
	@echo "  - start_docker: start docker container."
	@echo "  - stop_docker: stop docker container."
	@echo "  - build_container: make docker container."
	@echo "  - rm_docker_image: remove docker container."

.PHONY: build
build:
	@echo "Building site"
	- docker exec -w "/site" jekyll_site bundle exec jekyll build --config _config_local.yml

.PHONY: run
run:
	@echo "Runs site locally"
	- docker exec -w "/site" jekyll_site bundle exec jekyll serve --config _config_local.yml

.PHONY: build_container
build_container:
	@echo "Build docker container"
	- docker run -d --net=host -p 4000:4000 --name jekyll_site -v $(PWD):/site -w "/site" jekyll/jekyll:3.5 top
	- docker exec -w "/site" jekyll_site bundle install
	- docker stop jekyll_site

.PHONY: start_docker
start_docker:
	@echo "Start docker container"
	- docker container start jekyll_site

.PHONY: stop_docker
stop_docker:
	@echo "Stop docker container"
	- docker container stop jekyll_site

.PHONY: rm_docker_image
rm_docker_image: stop_docker
	@echo "Deleting docker container"
	- docker container rm jekyll_site

.PHONY: clean
clean:
	- bundle exec jekyll clean