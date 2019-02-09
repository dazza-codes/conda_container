
SHELL = /bin/bash

.ONESHELL:

LIB ?= src

CONDA_ENV ?= conda-tmp-env

pyinit:
	@export CONDA_ENV=$(CONDA_ENV)
	@./conda_setup.sh -id

pyclean:
	@rm -rf .coverage coverage.xml report.xml
	@find . -type d -name '__pycache__' -exec rm -rf {} +
	@find . -type d -name '.pytest_cache*' -exec rm -rf {} +
	@find . -type d -name '.mypy_cache*' -exec rm -rf {} +

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
	@yapf -ri --verbose ./

pylint: pyclean
	@pylint $(LIB)
	@pylint --disable=missing-docstring tests

pytest:
	@pytest

pytypehint:
	@mypy $(LIB) tests

.PHONY: pyinit pyclean pycoverage pyflake8 pyformat pylint pytest pytypehint

