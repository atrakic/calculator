GO_FLAGS   ?=
NAME       := calculator
BIN        := "./bin"
SRC        := $(shell git ls-files "*.go")
OUTPUT_BIN ?= $(BIN)/$(NAME)

PACKAGE    := github.com/atrakic/$(NAME)
VERSION    = v0.1.0
GIT_REV    ?= $(shell git rev-parse --short HEAD)
SOURCE_DATE_EPOCH ?= $(shell date +%s)

ifeq (, $(shell which golangci-lint))
$(warning "could not find golangci-lint in $(PATH), run: curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh")
endif

ifeq ($(shell uname), Darwin)
DATE       ?= $(shell TZ=UTC date -j -f "%s" ${SOURCE_DATE_EPOCH} +"%Y-%m-%dT%H:%M:%SZ")
else
DATE       ?= $(shell date -u -d @${SOURCE_DATE_EPOCH} +"%Y-%m-%dT%H:%M:%SZ")
endif


.PHONY: run build mod install fmt lint test install_deps clean


run: build
	$(OUTPUT_BIN)

build:
	go build ${GO_FLAGS} \
	-ldflags "-w -s -X ${PACKAGE}/cmd.version=${VERSION} -X ${PACKAGE}/cmd.commit=${GIT_REV} -X ${PACKAGE}/cmd.date=${DATE}" \
	-a -tags netgo -o ${OUTPUT_BIN} main.go

fmt:
	test -z $(shell gofmt -l $(SRC)) || (gofmt -d $(SRC); exit 1)

test: install_deps
	go test ./...

lint:
	golangci-lint run -v

mod:
	go mod tidy
	go mod vendor

install_deps:
	go get -v ./...

install:
	go install -v ./...

clean:
	rm -rf $(BIN)
