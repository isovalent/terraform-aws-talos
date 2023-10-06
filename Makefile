SHELL := /bin/bash

.PHONY: docs

## https://terraform-docs.io/user-guide/introduction/
docs:
	terraform-docs .