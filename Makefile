# https://www.gnu.org/software/make/manual/html_node/Makefile-Conventions.html

.SUFFIXES:

SHELL = /bin/bash

.ONESHELL:

LIB ?= src

CONDA_ENV ?= conda-template

conda-ci:
ifdef CI
	export CONDA_ENV=base
	source /opt/conda/etc/profile.d/conda.sh  # continuumio/miniconda3
	conda env update --name "$(CONDA_ENV)" --file environment.yml 
	conda activate "$(CONDA_ENV)"
	pip install -r requirements.dev
	pip install -r requirements.ci
endif

conda-dev:
	@export CONDA_ENV=$(CONDA_ENV)
	@source conda_funcs.sh
	@_conda3_env
	@_conda3_init
	@_conda3_env_create
	@conda activate $(CONDA_ENV)
	@_conda3_env_install
	@_conda3_env_pip_install
	@_conda3_env_pip_install_dev

pyclean:
	@rm -rf build dist .eggs *.egg-info
	@rm -rf .benchmarks .coverage coverage.xml htmlcov report.xml .tox
	@find . -type d -name '.mypy_cache' -exec rm -rf {} +
	@find . -type d -name '__pycache__' -exec rm -rf {} +
	@find . -type d -name '*pytest_cache*' -exec rm -rf {} +

pycoverage:
	@pytest -W ignore::DeprecationWarning \
		--cov-config .coveragerc \
		--verbose \
		--cov-report term \
		--cov-report xml \
		--cov=$(LIB) tests

pydocs: pyclean
	@cd docs && \
		if test -f Makefile; then \
			make html && \
			echo -e "\nBuild successful! View docs at docs/_build/html/index.html.\n"; \
		else \
			echo -e "\nRun sphinx-quickstart\n"; \
		fi

pyflake8: pyclean
	@flake8 --ignore=E501 $(LIB)

pyformat: pyclean
	@black $(LIB) tests

pylint: pyclean
	@pylint --disable=missing-docstring tests
	@pylint $(LIB)

pytest:
	@pytest

pytypehint:
	@mypy $(LIB) tests

.PHONY: conda-ci conda-dev pyclean pycoverage pyflake8 pyformat pylint pytest pytypehint


#
# Docker image
#

IMAGE = conda_template
VERSION = latest

build:
	git rev-parse HEAD > version
	docker build -t $(IMAGE) .
	rm version

# Auto-clean is disabled by leaving the value empty
AUTOCLEAN ?= 

clean:
	@IMAGES=$$(docker images | grep '$(IMAGE)' | awk '{print $$1 ":" $$2}')
	@if test -n "$${IMAGES}"; then \
		if test -n "$(AUTOCLEAN)"; then \
			docker rmi -f "$${IMAGES}" 2> /dev/null || true; \
			docker system prune -f; \
		else \
			echo "$${IMAGES}" | xargs -n1 -p -r docker rmi; \
			docker system prune; \
		fi; \
	fi

history: build
	docker history $(IMAGE)

run: build
	docker run --rm -it $(IMAGE) /bin/bash -l

.PHONY: build clean history run

