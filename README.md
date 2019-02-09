# Conda Project Template


## Install

See [INSTALL](INSTALL.md)

## Usage

This is a conda project template.  It's intended to be used as a starting point
for new repositories that will use conda for a python project.

### Choices made for this template

The following choices were made in creating this template project that
requires conda to manage dependencies.

- use `requirements.txt` instead of `environment.yml`
  - both conda and pip can work with simple `requirements.txt` files
  - a `requirements.txt` can be installed into any conda env, even `base`
  - a `requirements.dev` file works the same as `requirements.txt` to
    manage the development dependencies and both files can be used
    in one `conda install` command with multiple `--file` arguments

- if an `environment.yml` file is used:
  - it has no options to separate development dependencies,
    so they might be installed by pip from `requirements.dev` after
    the environment is created and activated
  - some python packages have inconsistent names or installation
    inconsistencies between conda and pypi/pip packaging systems;
    in some cases, it might help to have an `environment.yml` file
    and both `requirements.txt` and `requirements.dev` so that first
    conda can install from `environment.yml` and then pip can install
    from the `requirements.*` files.

- use make targets with a `py` prefix
  - the `py` prefix is used like a namespace
  - the Makefile might include additional make rules, e.g.
    rules to build docker images and run containers

- the `conda_setup.sh` utility helps to automate finding conda from
  either miniconda3 or anaconda3 and managing a conda env with a
  few command line options
  - it assumes that `requirements.txt` and `requirements.dev` are
    the only files needed to specify the dependencies; it's not
    yet designed to handle more advanced dependency management
  - the `conda_funcs.sh` can be sourced to use a variety of small
    utility functions in `bash`; they have an `_conda3` namespace
    prefix.


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

