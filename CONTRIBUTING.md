
# Contributing

## Get Started

Get started with `make pyinit` to create a new python environment for the project.
Activate the new environment and then explore the `make py*` targets.

## Dependencies

The library dependencies are in `requirements.txt` and the development
dependencies are in `requirements.dev`.

## Development

The `make` targets abstract away the details of development tools, but it's
important to understand [conda](https://docs.conda.io/en/latest/index.html).

- use a [github-flow](https://guides.github.com/introduction/flow/)
  - checkout a new branch off the master branch
  - add changes to the `lib` and `tests`
  - add content to `docs`
- the test suite uses [pytest](https://docs.pytest.org/en/latest/)
  - `make pytest` and `make pycoverage`
- the documentation is built with [sphinx](http://www.sphinx-doc.org/en/master/usage/quickstart.html)
  - run the `sphinx-quickstart` if the `docs` are not setup
  - `make pydocs`
- format code with [yapf](https://github.com/google/yapf)
  - `make pyformat`
- check code with [flake8](http://flake8.pycqa.org/en/latest/)
  - `make pyflake8`
- `make pyclean` to remove stale test and build artifacts

Once it's passing locally, push the new branch to the origin and create a merge
request.  The CI pipelines will run a suite of tests on each new commit to the
merge request and most of them must pass to be able to merge the branch to
master.  Request a code review from a project maintainer.
