help: ## Print this help
	@grep --no-filename -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sed 's/:.*##/·/' | sort | column -ts '·' -c 120

-include rules.mk

all: help

build: site/index.html  ## Build the site

serve: venv ## Serve the site locally (set MKDOCS_ARGS for extra args)
	poetry run mkdocs serve ${MKDOCS_ARGS}

test: ## Run the tests
