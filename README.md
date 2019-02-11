# Conda Project Template


## Install

See [INSTALL](INSTALL.md)

## Usage

This is a conda project template.  It's intended to be used as a starting point
for new repositories that will use conda for a python project.

The make rules and the `conda_setup.sh` script try to provide some layers of
abstraction around conda and pip workflows.  When they work as expected, the
make rules are the highest level of abstraction provided.  However, due to some
difficulties with conda in subshells, the `conda_setup.sh` and associated
`conda_funcs.sh` provide additional lower level abstractions.

### Choices made for this template

The following choices were made in creating this template project that
requires conda and pip to manage dependencies.  The recommended workflow
is to create an conda environment and then install dependencies, like:
```
# CONDA_ENV is the name of a conda environment (it can be `base`)
CONDA_ENV=conda_template
./conda_setup.sh -c  # create CONDA_ENV
conda activate $CONDA_ENV  # do this manually, it's not automated
./conda_setup.sh -i   # install/update CONDA_ENV with environment.yml
./conda_setup.sh -pi  # install/update CONDA_ENV with requirements.txt
./conda_setup.sh -pd  # install/update CONDA_ENV with requirements.dev
```

- use `environment.yml` as the primary dependency specification
  - some python packages have inconsistent names or installation inconsistencies
    between conda and pypi/pip packaging systems; in some cases, it might help
    to have both an `environment.yml` file and a `requirements.txt` so that
    first conda can install from `environment.yml` and then pip can install from
    the `requirements.txt` file.
  - a `requirements.txt` file should contain only additional pip specific
    packages for production purposes
  - a `requirements.dev` file works the same as `requirements.txt` to
    manage the development dependencies
  - use only production dependencies in `environment.yml` and `requirements.txt`
    - conda and pip have no conventions to separate development and test
      dependencies from production dependencies (but see pipenv for example)
    - use `requirements.dev` to isolate them and install with pip, after
      the environment is created and activated

- use make targets with a `py` prefix
  - the `py` prefix is used like a namespace
  - the Makefile might include additional make rules, e.g.
    rules to build docker images and run containers

- the `conda_setup.sh` utility helps to automate finding conda from
  either miniconda3 or anaconda3 and managing a conda env with a
  few command line options
  - if necessary, it can use pyenv to install miniconda3-latest
  - it has options to install from `environment.yml`, `requirements.txt`
    and `requirements.dev`
  - the `conda_funcs.sh` can be sourced to use a variety of small
    utility functions in `bash`; they have an `_conda3` namespace
    prefix; these are intended to be private functions


## Contributing

See [CONTRIBUTING](CONTRIBUTING.md)


## Migrating template code to a new git repository

This repository can be used to populate a new project repository by using
multiple git remotes.  It's not the only way to migrate code to a new repository
-- for example, using a git export can help to do a clean migration with no git
history, if that is required.

```
NEW_REPO={new_repo_name}
NEW_REPO_URL={new_repo_clone_url}


cd ~/tmp/
git clone git@github.com:darrenleeweber/conda_template.git
cd conda_template/
git remote -v
# origin    git@github.com:darrenleeweber/conda_template.git (fetch)
# origin    git@github.com:darrenleeweber/conda_template.git (push)

git remote add ${NEW_REPO} ${NEW_REPO_URL}
git remote -v
# origin    git@github.com:darrenleeweber/conda_template.git (fetch)
# origin    git@github.com:darrenleeweber/conda_template.git (push)
# ${NEW_REPO}  ${NEW_REPO_URL} (fetch)
# ${NEW_REPO}  ${NEW_REPO_URL} (push)

git fetch -ap
git push -u ${NEW_REPO} --all
git push -u ${NEW_REPO} --tags

cd ..
mv conda_template ${NEW_REPO}
cd ${NEW_REPO}/
git remote rm origin
git remote rename ${NEW_REPO} origin
```

