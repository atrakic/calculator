MAKEFLAGS += --silent
.DEFAULT_GOAL := help

GO_FLAGS   ?=
NAME       := calculator
BIN        := "./bin"
SRC        := $(shell git ls-files "*.go")
OUTPUT_BIN ?= $(BIN)/$(NAME)

PACKAGE    := github.com/atrakic/$(NAME)
VERSION    := v0.1.0
GIT_REV    ?= $(shell git rev-parse --short HEAD)
SOURCE_DATE_EPOCH ?= $(shell date +%s)

ifeq ($(shell uname), Darwin)
DATE       ?= $(shell TZ=UTC date -j -f "%s" ${SOURCE_DATE_EPOCH} +"%Y-%m-%dT%H:%M:%SZ")
else
DATE       ?= $(shell date -u -d @${SOURCE_DATE_EPOCH} +"%Y-%m-%dT%H:%M:%SZ")
endif

run: ## Run
	test -f $(OUTPUT_BIN) || $(MAKE) build
	$(OUTPUT_BIN)

build: ## Build
	go build ${GO_FLAGS} \
	-ldflags "-w -s -X ${PACKAGE}/cmd.version=${VERSION} -X ${PACKAGE}/cmd.commit=${GIT_REV} -X ${PACKAGE}/cmd.date=${DATE}" \
	-a -tags netgo -o ${OUTPUT_BIN} main.go

fmt:
	test -z $(shell gofmt -l $(SRC)) || (gofmt -d $(SRC); exit 1)

test: install_deps
	go test ./...

ifeq (, $(shell which golangci-lint))
$(warning "could not find golangci-lint in $(PATH), run: curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh")
endif

lint:
	golangci-lint run -v

mod:
	go mod tidy
	go mod vendor

install_deps:
	go get -v ./...

install: ## Install this cli app in your $GOPATH/bin
	go install -v ./...

release: ## Release (eg. V=0.0.1)
	 @[ "$(V)" ] \
		 && read -p "Press enter to confirm and push tag v$(V) to origin, <Ctrl+C> to abort ..." \
		 && gsed -e "s/^VERSION    :=.*/VERSION    := $(V)/" Makefile \
		 && git add Makefile \
		 && git commit -m "chore(version): bump to version: $(V)" \
		 && git tag v$(V) -m "chore: v$(V)" \
		 && git push origin v$(V) -f \
		 && if [ ! -z "$(GITHUB_TOKEN)" ] ; then \
			curl \
			  -H "Authorization: token $(GITHUB_TOKEN)" \
				-X POST	\
				-H "Accept: application/vnd.github.v3+json"	\
				https://api.github.com/repos/atrakic/$(NAME)/releases \
				-d "{\"tag_name\":\"$(V)\",\"generate_release_notes\":true}"; \
			fi;

clean: ## Clean up
	rm -rf $(BIN)

help:
	awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: run build mod install fmt lint test install_deps clean

-include include.mk
