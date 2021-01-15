#!/usr/bin/env make

#
#
# Default target
#
#
auto:

#
#
# Generic configuration
#
#

# https://ftp.gnu.org/old-gnu/Manuals/make-3.79.1/html_chapter/make_7.html
# https://stackoverflow.com/a/26936855/1954789
SHELL := /bin/bash
.SECONDEXPANSION:

ROOT = $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
SYNOLOGY_HOST = synology
GPG_KEY="313DD85CEFADAF7E"
DOCKERS = $(shell find dockers/ -mindepth 1 -maxdepth 1 -type d )

export PATH := $(ROOT)/jehon-base-minimal/usr/bin:$(PATH)

#
#
# Generic functions
#
#

#
#
# First install
#
#
.PHONY: setup-computer
setup-computer:
	sudo apt install -y debhelper git-buildpackage
	make packages-build
	sudo dpkg -i repo/jehon-base-minimal_*.deb || true
	sudo apt install -f -y
	sudo jehon-base-repositories/usr/bin/jh-apt-add-packages-key.sh
	sudo apt update
	sudo snap install --classic go
	@echo "You should add "
	@echo ". $(ROOT)/setup-profile.sh "
	@echo "in your profile"

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

.PHONY: all-dump
.PHONY: all-setup
.PHONY: all-clean
.PHONY: all-build
.PHONY: all-test
.PHONY: all-dump
.PHONY: all-stop

#
#
# Globals
#
#

all-dump: global-dump

.PHONY: global-dump
global-dump:
	$(info * PWD:            $(shell pwd))
	$(info * PATH:           $(shell echo $$PATH))
	$(info * ROOT:           $(ROOT))
	$(info * DOCKERS:        $(DOCKERS))
	$(info * GPG_KEY:        $(GPG_KEY))
	$(info * SYNOLOGY_HOST:  $(SYNOLOGY_HOST))

#
#
# Dockers
#
#
all-clean: dockers-clean
all-build: dockers-build
all-stop: dockers-stop

.PHONY: dockers-clean
dockers-clean: dockers-stop
	rm -f $(ROOT)/dockers/*.dockerbuild

.PHONY: dockers-build
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

.PHONY: dockers-stop
dockers-stop:
	docker image prune -f

#
#
# Externals
#
#
all-clean: externals-clean
all-build: externals-build

.PHONY: externals-clean
externals-clean:
	rm -f externals/shuttle-go/shuttle-go

.PHONY: externals-update
externals-update:
	# TODO: check this !
	git subtree pull --prefix externals/shuttle-go git@github.com:abourget/shuttle-go.git master --squash

.PHONY: externals-build
externals-build: externals/shuttle-go/shuttle-go

externals/shuttle-go/shuttle-go: externals/shuttle-go/*.go
	cd externals/shuttle-go && ./build.sh


#
#
# Node
#
#
all-setup: node-setup

.PHONY: node-build
node-setup: node_modules/.dependencies

node_modules/.dependencies: package.json package-lock.json
	npm ci

#
#
# Packages
#
#
all-clean: packages-clean
all-build: packages-build
#all-test: packages-test

.PHONY: packages-clean
packages-clean:
	make -f debian/rules clean
	rm -f  $(ROOT)/debian/*.debhelper
	rm -f  $(ROOT)/debian/*.substvars
	rm -fr $(ROOT)/repo
	rm -f  $(ROOT)/jehon-debs_

.PHONY: packages-build
packages-build: repo/Release

repo/Release.gpg: repo/Release
	gpg --sign --armor --detach-sign --default-key "$(GPG_KEY)" --output repo/Release.gpg repo/Release

repo/Release: repo/Packages dockers/jehon-docker-build.dockerbuild
	$(call in_docker,cd repo && apt-ftparchive -o "APT::FTPArchive::Release::Origin=jehon" release . > Release)

repo/Packages: repo/index.html
	cd repo && dpkg-scanpackages -m . | sed -e "s%./%%" > Packages

repo/index.html: dockers/jehon-docker-build.dockerbuild \
		debian/changelog \
		jehon-base-minimal/usr/bin/shuttle-go

	@rm -fr repo
	@mkdir -p repo
	rm -f repo/jehon-*.deb
#echo "************ build indep ******************"
	$(call in_docker,rsync -a /app /tmp/ && cd /tmp/app && debuild -rsudo --no-lintian -uc -us --build=binary && cp ../jehon-*.deb /app/repo/)
#echo "************ build arch:armhf *************"
#call in_docker,rsync -a /app /tmp/ && cd /tmp/app && debuild -rsudo --no-lintian -uc -us --build=any --host-arch armhf && ls -l /tmp && cp ../jehon-*.deb /app/repo/)
	mkdir -p "$(dir $@)"

# Generate the index.html for github pages
	echo "<html>" > "$@"; \
	for F in repo/* ; do \
		BF=$$(basename "$$F"); echo "<a href='$$BF'>$$(date "+%m-%d-%Y %H:%M:%S" -r "$$F") $$BF</a><br>" >> "$@"; \
	done; \
	echo "</html>" >> "$@";

jehon-base-minimal/usr/bin/shuttle-go: externals/shuttle-go/shuttle-go
	mkdir -p "$(dir $@)"
	cp externals/shuttle-go/shuttle-go "$@"

debian/changelog: dockers/jehon-docker-build.dockerbuild \
		debian/control \
		debian/*.postinst \
		debian/*.install \
		debian/*.templates \
		debian/*.triggers \
		debian/jehon-base-minimal.links \
		jehon-base-minimal/usr/bin/shuttle-go \
		$(shell find . -path "./jehon-*" -type f)

	$(call in_docker,gbp dch --git-author --ignore-branch --new-version=$(shell date "+%Y.%m.%d.%H.%M.%S") --distribution main)

debian/jehon-base-minimal.links: debian/jehon-base-minimal.links.add \
		$(shell find jehon-base-minimal/usr/share/jehon-base-minimal/etc -type f ) \
		Makefile
	(cd jehon-base-minimal/usr/share/jehon-base-minimal/etc \
		&& find * -type f -exec "echo" "/usr/share/jehon-base-minimal/etc/{} /etc/{}" ";" ) > "$@"
	cat debian/jehon-base-minimal.links.add >> "$@"

#
#
# Shell
#
#
all-test: shell-test
all-lint: shell-lint

.PHONY: shell-test
shell-test:
	run-parts --verbose --regex "test-.*" ./tests/shell/tests

.PHONY: shell-lint
shell-lint:
	@shopt -s globstar; \
	RES=0; \
	for f in jehon-*/**/*.sh bin/**/*.sh; do \
		shellcheck -x "$$f"; RES=$$? || $$RES; \
	done ; \
	exit $$RES


######################################
#
# Deploy
#
#
.PHONY: deploy
deploy: deploy-local deploy-synology

.PHONY: deploy-github
deploy-github: packages-build node-setup
	git remote -v

	UE="$$( git --no-pager show -s --format="%an" ) <$$( git --no-pager show -s --format="%ae" )>"; \
	set -x && ./node_modules/.bin/gh-pages --dist repo --user "$$UE" --remote "$${GIT_ORIGIN:origin}";

	@echo "***********************************************************************"
	@echo "***                                                                 ***"
	@echo "***   Go check this at http://jehon.github.io/packages/index.html   ***"
	@echo "***                                                                 ***"
	@echo "***********************************************************************"

.PHONY:
deploy-github-validate:
	wget https://jehon.github.io/packages/Packages -O tmp/Packages-from-github
	@echo "*** Check content ***"
	@grep "Source: jehon-debs" tmp/Packages-from-github > /dev/null
	@grep "Package: " tmp/Packages-from-github
	@grep "Version: " tmp/Packages-from-github | head -n 1
	wget https://jehon.github.io/packages/index.html

.PHONY: deploy-local
deploy-local: packages-build
	sudo ./setup-profile.sh
	sudo apt update || true
	sudo apt upgrade -y

.PHONY: deploy-synology
deploy-synology:
# Not using vf-
	jehon-base-minimal/usr/bin/jh-rsync-deploy.sh \
		./synology/ssh/root/ $(SYNOLOGY_HOST):/root/.ssh \
		--rsync-path=/bin/rsync \
		--chmod=F644

# Not using vf-
	jehon-base-minimal/usr/bin/jh-rsync-deploy.sh \
		"synology/scripts/" "$(SYNOLOGY_HOST):/volume3/scripts/synology" \
		--copy-links --rsync-path=/bin/rsync
