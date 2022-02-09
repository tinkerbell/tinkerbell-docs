# Only use the recipes defined in these makefiles
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
# Delete target files if there's an error
# This avoids a failure to then skip building on next run if the output is created by shell redirection for example
# Not really necessary for now, but just good to have already if it becomes necessary later.
.DELETE_ON_ERROR:
# Treat the whole recipe as a one shell script/invocation instead of one-per-line
.ONESHELL:
# Use bash instead of plain sh
SHELL := bash
.SHELLFLAGS := -o pipefail -euc

.PHONY: all build help serve test venv

venv: .venv/pyvenv.cfg
.venv/pyvenv.cfg:
	poetry install

site/index.html: venv
	poetry run mkdocs build

checkquotes:
	git grep '[“”]' | (grep -v rules.mk || :) | (! grep .)

checklinks: build
	./.github/workflows/check-links

