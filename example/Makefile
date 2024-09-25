SHELL := /bin/bash

.PHONY: apply
.DEFAULT_GOAL := help

## Deploys the infra using Terraform apply
apply: AUTO_APPROVE ?= true
apply: init
apply:
	terraform apply --auto-approve=$(AUTO_APPROVE)
	@chmod 600 $$(terraform output --raw path_to_kubeconfig_file)

## Destroys all infra originally created by the Terraform code
destroy: AUTO_APPROVE ?= true
destroy:
	terraform destroy --auto-approve=$(AUTO_APPROVE)
	@rm -f .timestamp

## Initialize Terraform (installs modules, plugins, etc.)
init:
	@if [ ! -f .timestamp ]; then\
		if [ "$$(uname)" == "Darwin" ]; then\
			out=$$(date -u -v+3d '+%Y-%m-%d') && echo -n "$$out" > .timestamp;\
		else\
			out=$$(date -u -d '+3 days' '+%Y-%m-%d') && echo -n "$$out" > .timestamp;\
		fi;\
	fi
	terraform init --upgrade

## Runs Terraform plan
plan:
	terraform plan

## Prints the export KUBECONFIG command for convenience
print-kubeconfig:
	@echo 'KUBECONFIG='$$(terraform output --raw path_to_kubeconfig_file)

## Prints the export TALOSCONFIG command for convenience
print-talosconfig:
	@echo 'TALOSCONFIG='$$(terraform output --raw path_to_talosconfig_file)

## Run infra tests from ./tests/* on cluster
test:
	./tests/cilium-connectivity-test.sh

## Generate/update terraform docs inside README.md (https://terraform-docs.io/user-guide/introduction/)
docs:
	terraform-docs .

# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

TARGET_MAX_CHAR_NUM=20
## Show this help
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
