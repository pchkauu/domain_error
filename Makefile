SHELL := /bin/sh

.PHONY: help deps format format-check analyze test check publish-dry-run diagrams

help:
	@echo "domain_error package commands"
	@echo ""
	@echo "  make deps"
	@echo "  make format"
	@echo "  make format-check"
	@echo "  make analyze"
	@echo "  make test"
	@echo "  make check"
	@echo "  make publish-dry-run"
	@echo "  make diagrams"

deps:
	dart pub get

format:
	dart format lib test example

format-check:
	dart format --output=none --set-exit-if-changed lib test example

analyze:
	dart analyze --fatal-infos

test:
	dart test

check: format-check analyze test

publish-dry-run:
	dart pub publish --dry-run

diagrams:
	./tool/render_diagrams.sh
