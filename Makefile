#!/usr/bin/env make

#
#
# Default target
#
#
auto:

clear:
	clear

#
#
# Generic configuration
#
#

# https://ftp.gnu.org/old-gnu/Manuals/make-3.79.1/html_chapter/make_7.html
# https://stackoverflow.com/a/26936855/1954789
SHELL := /bin/bash
.SECONDEXPANSION:

define itself
	$(MAKE) $(FLAGS) $(MAKEOVERRIDES) "$1"
endef

ROOT = $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
SYNOLOGY_HOST = synology
GPG_KEY = 313DD85CEFADAF7E
GPG_KEYRING = conf/generated/keyring.gpg
DOCKERS = $(shell find dockers/ -mindepth 1 -maxdepth 1 -type d )

VERSION_LAST_GIT=$(shell git log -1 --format="%at" | xargs -I{} date --utc -d @{} "+%Y.%m.%d.%H.%M.%S" )
VERSION_CURRENT_TIME_TAG=$(shell date --utc "+%Y%m%d%H%M%S")
ifeq "$(shell git status --porcelain)" ""
	VERSION=$(VERSION_LAST_GIT)
else
	VERSION=$(VERSION_LAST_GIT).$(VERSION_CURRENT_TIME_TAG)
endif

export PATH := $(ROOT)/usr/bin:$(PATH)

# Path to local crypted informations
SECRETS ?= $(shell jh-lib && echo "$$JH_SECRETS_FOLDER" 2> /dev/null)

#
#
# Generic functions
#
#

#
# find recursive dependencies in folder $1 (newer than $2)
#
# 1: folder where to look
# 2: base file to have files newer than this, to limit the length of the output
#
# See https://coderwall.com/p/cezf6g/define-your-own-function-in-a-makefile
define recursive-dependencies
	$(shell \
		if [ -r "$(2)" ]; then \
			find "$(1)" -name tests_data -prune -o -name tmp -prune -o -newer "$(2)"; \
		else \
			echo "$(1)/**";\
		fi \
	)
endef

#
# Run the command in a docker container
#
RUN_IN_DOCKER=docker run -e HOST_UID='$(shell id -u)' -e HOST_GID='$(shell id -g)' --mount 'source=$(ROOT),target=/app,type=bind' jehon/jehon-docker-build

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
	$(info * PWD:                      $(shell pwd))
	$(info * PATH:                     $(shell echo $$PATH))
	$(info * ROOT:                     $(ROOT))
	$(info * SECRETS:                  $(SECRETS))
	$(info * DOCKERS:                  $(DOCKERS))
	$(info * GPG_KEYRING:              $(GPG_KEYRING))
	$(info * GPG_KEY:                  $(GPG_KEY))
	$(info * SYNOLOGY_HOST:            $(SYNOLOGY_HOST))
	$(info * VERSION_LAST_GIT:         $(VERSION_LAST_GIT))
	$(info * VERSION_CURRENT_TIME_TAG: $(VERSION_CURRENT_TIME_TAG))
	$(info * VERSION:                  $(VERSION))

#
#
# Dockers
#
#
all-clean: dockers-clean
all-stop: dockers-stop

#
# Check if dockers does exists or not
#
#  for docker, the file dockers/*/.dockerexists track the fact that the docker
#  image exists. So, we need to check here if it is really the case.
#

#
#
# Docker remove
#
#
*: docker-init

docker-init:
	@for L in dockers/* ; do I="jehon/$$(basename $$L)"; if docker image ls | grep "$$I" > /dev/null; then echo "$$I"; else rm -f $$L/.dockerbuild ; fi; done

.PHONY: dockers-clean
dockers-clean: dockers-stop
	rm -f dockers/*/.dockerbuild

.PHONY: dockers-build
dockers-build: $(addsuffix /.dockerbuild,$(DOCKERS))

.PHONY: dockers/*
dockers/*: dockers/*/.dockerbuild

$(addsuffix /.dockerbuild,$(DOCKERS)): $$(call recursive-dependencies,dockers/$$*,$$@)

	@DNAME=$$(dirname "$@"); FNAME=$$(basename $$DNAME); INAME="jehon/$$FNAME"; \
	echo "Building $$INAME"; \
	cd "$$DNAME" && docker build -t "$$INAME" . ;
	touch "$@"

# Enrich dependencies
dockers/jenkins/.dockerbuild: \
	dockers/jenkins/shared/generated/authorized_keys \
	dockers/jenkins/shared/generated/jenkins-github-ssh \
	dockers/jenkins/shared/generated/jenkins-master-to-slave-ssh \
	dockers/jenkins/shared/generated/secrets.properties \
	dockers/jenkins/shared/generated/timezone

.PHONY: dockers-stop
dockers-stop:
	docker image prune -f

dockers-kill:
	@for D in $(DOCKERS); do \
		BN="$$(basename "$$D" )"; \
		echo "* Killing $$BN"; \
		docker kill "jehon/$$BN" || true; \
	done; \
	echo "* Killing done";

#
#
# Externals
#
#
# all-clean: externals-clean
# all-build: externals-build

# .PHONY: externals-clean
# externals-clean:
# 	rm -f externals/shuttle-go/shuttle-go

# .PHONY: externals-update
# externals-update:
# 	# TODO: check this !
# 	git subtree pull --prefix externals/shuttle-go git@github.com:abourget/shuttle-go.git master --squash

# .PHONY: externals-build
# externals-build: externals/shuttle-go/shuttle-go

# externals/shuttle-go/shuttle-go: externals/shuttle-go/*.go
# TODO: in docker !
# 	cd externals/shuttle-go && ./build.sh


#
#
# Files
#
#

all-clean: files-clean
all-build: files-build
all-test: files-test
all-lint: files-lint

files-clean:
	rm -fr conf/generated
	rm -fr dockers/jenkins/shared/generated/
#	rm -f usr/bin/shuttle-go
	rm -f usr/share/jehon/etc/ssh/authorized_keys/jehon

.PHONY: files-build
files-build: \
		usr/share/jehon/etc/ssh/authorized_keys/jehon \

#		usr/bin/shuttle-go

	find tests -name "*.sh" -exec "chmod" "+x" "{}" ";"
	find bin -exec "chmod" "+x" "{}" ";"
	find usr -name "*.sh" -exec "chmod" "+x" "{}" ";"
	find usr/bin -exec "chmod" "+x" "{}" ";"
	find usr/lib/jehon/postUpdate -exec "chmod" "+x" "{}" ";"

.PHONY: files-test
files-test: files-shell-test

.PHONY: files-shell-test
files-shell-test: files-build
	run-parts --verbose --regex "test-.*" ./tests/shell

.PHONY: files-lint
files-lint:
	@shopt -s globstar; \
	RES=0; \
	for f in jehon-*/**/*.sh bin/**/*.sh; do \
		shellcheck -x "$$f"; RES=$$? || $$RES; \
	done ; \
	exit $$RES


$(GPG_KEYRING): $(SECRETS)/crypted/jenkins/packages-gpg
	@mkdir -p "$(dir $@)"
	@rm -f $(GPG_KEYRING)
	gpg --no-default-keyring --keyring="$@" --import "$<"

dockers/jenkins/shared/generated/authorized_keys: usr/share/jehon/etc/ssh/authorized_keys/jehon
	@mkdir -p "$(dir $@)"
	cat "$<" | grep -v -e "^#" | grep -v -e "^\$$"> "$@"

dockers/jenkins/shared/generated/secrets.properties: $(SECRETS)/crypted/jenkins/jenkins-secrets.properties
	@mkdir -p "$(dir $@)"
	cp "$<" "$@"

dockers/jenkins/shared/generated/jenkins-github-ssh: $(SECRETS)/crypted/jenkins/jenkins-github-ssh
	@mkdir -p "$(dir $@)"
	cp "$<" "$@"

dockers/jenkins/shared/generated/jenkins-master-to-slave-ssh: $(SECRETS)/crypted/jenkins/jenkins-master-to-slave-ssh
	@mkdir -p "$(dir $@)"
	cp "$<" "$@"

dockers/jenkins/shared/generated/secrets.yml: $(SECRETS)/crypted/jenkins/jenkins-secrets.yml
	@mkdir -p "$(dir $@)"
	cp "$<" "$@"

dockers/jenkins/shared/generated/timezone: usr/share/jehon/etc/timezone
	@mkdir -p "$(dir $@)"
	cat "$<" | tr -d '\n' > "$@"

# usr/bin/shuttle-go: externals/shuttle-go/shuttle-go
# 	@mkdir -p "$(dir $@)"
# 	cp externals/shuttle-go/shuttle-go "$@"

usr/share/jehon/etc/ssh/authorized_keys/jehon: $(call recursive-dependencies,conf/keys/admin,$@)
	@mkdir -p "$(dir $@)"
	( \
		echo -e "\n\n#\n#\n# Access \n#\n#   Generated on $$(date)\n#\n";\
		for F in conf/keys/admin/* ; do \
			echo -e "\\n# $$F"; \
			cat "$$F"; \
			echo ""; \
		done \
	) > "$@"; \

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
	rm -fr tmp

all-build: packages-build
all-test: packages-test

.PHONY: packages-clean
packages-clean:
	make -f debian/rules clean
	rm -f  $(ROOT)/debian/jehon.links
	rm -f  $(ROOT)/debian/*.debhelper
	rm -f  $(ROOT)/debian/*.substvars
	rm -fr $(ROOT)/repo
	rm -f  $(ROOT)/jehon-debs_

.PHONY: packages-build
packages-build: repo/Release

packages-test: packages-build
	run-parts --verbose --regex "test-.*" ./tests/packages

packages-sign: repo/Release.gpg

repo/Release.gpg: repo/Release $(GPG_KEYRING)
	gpg --sign --armor --detach-sign --no-default-keyring --keyring=$(GPG_KEYRING) --default-key "$(GPG_KEY)" --output repo/Release.gpg repo/Release

repo/Release: repo/Packages dockers/jehon-docker-build/.dockerbuild
	$(RUN_IN_DOCKER) "cd repo && apt-ftparchive -o "APT::FTPArchive::Release::Origin=jehon" release ." > "$@"

repo/Packages: repo/index.html repo/jehon.deb
	$(RUN_IN_DOCKER) "cd repo && dpkg-scanpackages -m ." | sed -e "s%./%%" > "$@"

repo/index.html: repo/.built
# Generate the index.html for github pages
	echo "<html>" > "$@"; \
	for F in repo/* ; do \
		BF=$$(basename "$$F"); echo "<a href='$$BF'>$$(date "+%m-%d-%Y %H:%M:%S" -r "$$F") $$BF</a><br>" >> "$@"; \
	done; \
	echo "</html>" >> "$@";

repo/jehon.deb: repo/.built
# create jehon.deb for /start...
	LD="$$( find repo/ -name "jehon_*.deb" | sort -r | head -n 1 )" && cp "$$LD" "$@"

repo/.built: dockers/jehon-docker-build/.dockerbuild \
		debian/control \
		debian/*.postinst \
		debian/*.install \
		debian/*.templates \
		debian/*.triggers \
		debian/jehon.links \
		$(shell find . -path "./jehon-*" -type f) \
		usr/share/jehon/etc/ssh/authorized_keys/jehon

#		usr/bin/shuttle-go

	$(call itself,files-build)
	@rm -fr repo
	@mkdir -p "$(dir $@)"
	$(RUN_IN_DOCKER) "rsync -a /app /tmp/ \
		&& cd /tmp/app \
		&& gbp dch --git-author --ignore-branch --new-version=$(VERSION) --distribution main \
		&& debuild -rsudo --no-lintian -uc -us --build=binary \
		&& cp ../jehon*.deb /app/repo/ "

#echo "************ build arch:armhf *************"
# && debuild -rsudo --no-lintian -uc -us --build=any --host-arch armhf && ls -l /tmp && cp ../jehon-*.deb /app/repo/
	touch "$@"

debian/jehon.links: $(shell find usr/share/jehon/etc -type f )
	(cd usr/share/jehon/etc \
		&& find * -type "f,l" -exec "echo" "/usr/share/jehon/etc/{} /etc/{}" ";" ) > "$@"

######################################
#
# Deploy
#
#
.PHONY: deploy
deploy: deploy-local deploy-synology

.PHONY: deploy-github
deploy-github: repo/Release.gpg node-setup
# TODO: in docker ?
	git remote -v

	UE="$$( git --no-pager show -s --format="%an" ) <$$( git --no-pager show -s --format="%ae" )>"; \
	set -o xtrace && ./node_modules/.bin/gh-pages --dist repo --user "$$UE" --remote "$${GIT_ORIGIN:origin}";

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
	. jh-lib; \
	. jh-secrets; \
	set -o xtrace ; \
	SSHPASS=$$JH_NAS_ADMIN_PASS sshpass -e \
		rsync \
			"synology/scripts/" "$$JH_NAS_ADMIN_USER@$$JH_NAS_IP::scripts/synology" \
			-e ssh \
			--recursive --times \
			--omit-dir-times \
			--itemize-changes \
			--modify-window=2 \
			--delete \
			--copy-links \
			--exclude ".git" \
			--exclude "tmp" \
		 	--chmod=F755 --chmod=D755

## fix it:
# ln -s /volume3/scripts/synology/authorized_keys /root/.ssh/authorized_keys
# chmod 644 /volume3/scripts/synology/authorized_keys
# chmod 755 /volume3/scripts/synology/
