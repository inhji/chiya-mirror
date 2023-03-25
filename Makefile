SHELL := /bin/bash

all: build

build:
	source ~/.asdf/asdf.sh &&  bash scripts/build.sh