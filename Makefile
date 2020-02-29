#!/usr/bin/env make

#
#
# Default target
#
#
auto:

#
#
# First install
#
#
setup-computer:
	sudo apt install -y debhelper git-buildpackage
	make packages-build
	sudo dpkg -i repo/jehon-base-minimal_*.deb || true
	sudo apt install -f -y
	sudo jh-apt-install-common-keys
	sudo apt update

#
#
# Generic configuration
#
#

# https://ftp.gnu.org/old-gnu/Manuals/make-3.79.1/html_chapter/make_7.html
# https://stackoverflow.com/a/26936855/1954789
SHELL := /bin/bash
.SECONDEXPANSION:

#
#
# System variables
#
#
ROOT = $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
SYNOLOGY_HOST = synology
GPG_KEY="313DD85CEFADAF7E"

#
#
# Product variables
#
#
DOCKERS = $(shell find dockers/ -mindepth 1 -maxdepth 1 -type d )

#
#
# Generic functions
#
#

# See https://coderwall.com/p/cezf6g/define-your-own-function-in-a-makefile
# 1: folder where to look
# 2: base file to have files newer than, to limit the length of the output
define recursive-dependencies
	$(shell \
		if [ -r "$(2)" ]; then \
			find "$(1)" -name tests_data -prune -o -name tmp -prune -o -newer "$(2)"; \
		else \
			echo "$(1)";\
		fi \
	)
endef

# 1: command to be run
define in_docker
	docker run -e HOST_UID="$(shell id -u)" -e HOST_GID="$(shell id -g)" --mount "source=$(ROOT),target=/app,type=bind" jehon/jehon-docker-build "$1"
endef

#
#
# Generic targets
#
#

all-clean: dockers-clean packages-clean
all-test: shell-test
all-build: dockers-build packages-build

debug:
	$(info * PWD:     $(shell pwd))
	$(info * DOCKERS: $(DOCKERS))

publish: deploy-local deploy-synology-repo
	git push

#
#
# Dockers
#
#
dockers: dockers-build

dockers-clean:
	rm -f $(ROOT)/dockers/*.dockerbuild

dockers-build: $(addsuffix .dockerexists, $(DOCKERS)) $(addsuffix .dockerbuild, $(DOCKERS))

%.dockerexists:
	@if [[ -r "$@" ]] && [[ "$$(docker images -q "jehon/$@" 2>/dev/null)" == "" ]]; then \
		rm "$@.dockerbuild"; \
	fi ;

%.dockerbuild: $$(call recursive-dependencies,dockers/$$*,$$@)
	@echo "Building $@ from $(notdir $(basename $@))"
	cd $(basename $@) && \
		docker build -t "jehon/$(notdir $(basename $@))" .
	@touch "$@"


#
#
# Packages
#
#
packages-clean:
	make -f debian/rules clean
	rm -f $(ROOT)/debian/*.debhelper
	rm -f $(ROOT)/debian/*.substvars
	rm -f $(ROOT)/repo/*
	rm -f $(ROOT)/jehon-debs_

packages-build: repo/Release

repo/Release.gpg:
	gpg --sign --armor --detach-sign --default-key "$(GPG_KEY)" --output repo/Release.gpg repo/Release

repo/Release: repo/Packages dockers/jehon-docker-build.dockerbuild
	$(call in_docker,cd repo && apt-ftparchive -o "APT::FTPArchive::Release::Origin=jehon" release . > Release)
	git add debian/changelog

repo/Packages: debian/debhelper-build-stamp
	@mkdir -p repo
	cd repo && \
		dpkg-scanpackages -m . | sed -e "s%./%%" > Packages

debian/debhelper-build-stamp: dockers/jehon-docker-build.dockerbuild debian/changelog
	@mkdir -p repo
	rm -f repo/jehon-*.deb
#echo "************ build indep ******************"
	$(call in_docker,rsync -a /app /tmp/ && cd /tmp/app && debuild -rsudo --no-lintian -uc -us --build=binary && ls -l /tmp && cp ../jehon-*.deb /app/repo/)
#echo "************ build arch:armhf *************"
#call in_docker,rsync -a /app /tmp/ && cd /tmp/app && debuild -rsudo --no-lintian -uc -us --build=any --host-arch armhf && ls -l /tmp && cp ../jehon-*.deb /app/repo/)

debian/changelog: dockers/jehon-docker-build.dockerbuild \
		debian/control \
		debian/*.postinst \
		debian/*.install \
		debian/*.templates \
		debian/*.triggers \
		$(shell find . -path "./jehon-*" -type f)
	$(call in_docker,gbp dch --git-author --ignore-branch --snapshot)

packages-release:
	@echo "**"
	@echo "**"
	@echo "** How to release ? **"
	@echo "** Set the version on the first line of the changelog **"
	@echo "**"
	@echo "**"
	gbp dch --git-author --release
	git add debian/changelog
	git commit -m "Releasing version $(shell dpkg-parsechangelog -l debian/changelog --show-field Version)"
	gbp tag
	git push
	git push --tags


#
#
# Shell
#
#
shell-test:
	run-parts --verbose --regex "test-.*" ./tests/shell/tests


######################
#
# Runtime 
#
######################


#
#
# Deploy
#
#
deploy: deploy-local deploy-synology

deploy-local: packages-build
	sudo apt update || true
	sudo apt upgrade -y

.PHONY: deploy-synology
deploy-synology: \
	deploy-synology-ssh \
	deploy-synology-scripts \
	deploy-synology-repo

.PHONY: deploy-synology-ssh
deploy-synology-ssh:
# Not using vf-
	jehon-base-minimal/usr/bin/jh-rsync-deploy.sh \
		./synology/ssh/root/ $(SYNOLOGY_HOST):/root/.ssh \
		--rsync-path=/bin/rsync \
		--chmod=F644

.PHONY: deploy-synology-scripts
deploy-synology-scripts:
# Not using vf-
	jehon-base-minimal/usr/bin/jh-rsync-deploy.sh \
		"synology/scripts/" "$(SYNOLOGY_HOST):/volume3/scripts/synology" \
		--copy-links --rsync-path=/bin/rsync

.PHONY: deploy-synology-repo
deploy-synology-repo: packages-build
# Not using vf-
	jehon-base-minimal/usr/bin/jh-rsync-deploy.sh \
		"repo/" "$(SYNOLOGY_HOST):/volume3/temporary/repo" \
			--rsync-path=/bin/rsync