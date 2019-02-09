#!/bin/bash

#
# This script is NOT a replacement for using 'conda' directly; the purpose of
# this script is for automation system to (a) discover where the 'conda' command
# is or source the right setup to enable it and (b) then use it to create a
# conda environment.  This script is useful when called from a Makefile or a
# github/gitlab CI system.
#


set -e

test -z "$CONDA_ENV" && export CONDA_ENV="conda-tmp-env"

#
# Find a conda installation
#
# - prefer Miniconda3 over Anaconda3 if they are both installed.
# - prefer user installations to global installations.
#

is_conda_function () {
    if type conda > /dev/null 2>&1; then
        conda_type=$(type -t conda)
        if [[ "${conda_type}" == "function" ]]; then
            return 0
        fi
    fi
    return 1
}

CONDA_FOUND=false

if is_conda_function; then
    CONDA_FOUND=true
elif which conda > /dev/null 2>&1; then
    CONDA_FOUND=true
fi


# Miniconda3
MINICONDA_SH="/miniconda3/etc/profile.d/conda.sh"
if ! $CONDA_FOUND && test -f "${HOME}${MINICONDA_SH}"; then
    echo "source ${HOME}${MINICONDA_SH}"
    source "${HOME}${MINICONDA_SH}" && CONDA_FOUND=true
fi
if ! $CONDA_FOUND && test -f ${MINICONDA_SH}; then
    echo "source ${MINICONDA_SH}"
    source ${MINICONDA_SH} && CONDA_FOUND=true
fi

# Anaconda3
ANACONDA_SH="/anaconda3/etc/profile.d/conda.sh"
if ! $CONDA_FOUND && test -f "${HOME}${ANACONDA_SH}"; then
    echo "source ${HOME}${ANACONDA_SH}"
    source "${HOME}${ANACONDA_SH}" && CONDA_FOUND=true
fi
if ! $CONDA_FOUND && test -f ${ANACONDA_SH}; then
    echo "source ${ANACONDA_SH}"
    source ${ANACONDA_SH} && CONDA_FOUND=true
fi


if ! $CONDA_FOUND; then
    echo "WARNING: did not find miniconda3 or anaconda3 'conda' command"
fi


#
# Install miniconda3 and update it
#

update_conda() {
    conda update --yes -n base -c defaults conda
}

install_miniconda3() {
    if uname -a | grep -q -E 'x86_64 GNU/Linux'; then
        curl -s -L -o miniconda_installer.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        bash miniconda_installer.sh
        rm miniconda_installer.sh
        update_conda
    elif uname -a | grep -q -E 'Darwin Kernel .*x86_64'; then
        curl -s -L -o miniconda_installer.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
        bash miniconda_installer.sh
        rm miniconda_installer.sh
        update_conda
    else
        echo "Unknown system requirements, use a manual install; see"
        echo "https://conda.io/en/latest/miniconda.html"
        return 1
    fi
}


#
# Functions called by CLI options
#

conda_env_active() {
    # assumes the active conda env is tagged by an '*'.
    if conda info --envs | grep -q -E "${CONDA_ENV}.*[*]+"; then
        return 0
    else
        echo "ERROR: conda env is not active: ${CONDA_ENV}"
        conda info --envs
        return 1
    fi
}

conda_env_exists() {
    if conda info --envs | grep -q "${CONDA_ENV}"; then
        return 0
    else
        echo "ERROR: conda env does not exist: ${CONDA_ENV}"
        conda info --envs
        return 1
    fi
}

conda_create() {
    echo "Create ${CONDA_ENV}"
    conda create --yes --name ${CONDA_ENV}
    conda_activate
}

conda_activate() {
    # this must be run in the primary bash shell
    echo <<ACTIVATE
#
# To activate this environment, use
#
#     $ conda activate ${CONDA_ENV}
#
# To deactivate an active environment, use
#
#     $ conda deactivate
ACTIVATE
}

conda_deactivate() {
    # this must be run in the primary bash shell
    echo <<DEACTIVATE
#
# To deactivate an active environment, use
#
#     $ conda deactivate
#
DEACTIVATE
}

conda_install() {
    conda_env_exists || conda_create
    echo "Install ${CONDA_ENV}"
    conda install --yes --name ${CONDA_ENV} \
        --channel conda-forge \
        --file requirements.txt
    conda clean -a -y -q
    conda_activate
}

conda_install_dev() {
    conda_env_exists || conda_create
    echo "Install ${CONDA_ENV}"
    conda install --yes --name ${CONDA_ENV} \
        --channel conda-forge \
        --file requirements.txt \
        --file requirements.dev
    conda clean -a -y -q
    conda_activate
}

conda_remove() {
    conda env remove --name ${CONDA_ENV}
}

conda_usage() {
    cat <<- USAGE
usage: $0 [option]

options:
-a  | --activate        info about 'conda activate $CONDA_ENV'
-d  | --deactivate      info about 'conda deactivate $CONDA_ENV'
-c  | --create          create $CONDA_ENV
-i  | --install         install $CONDA_ENV with requirements.txt
-id | --install_dev     install $CONDA_ENV plus requirements.dev
-l  | --list            conda env list
-r  | --remove          remove $CONDA_ENV
-h  | --help
USAGE
}

case $1 in
    -a | --activate )       conda_activate
                            exit
                            ;;
    -d | --deactivate )     conda_deactivate
                            exit
                            ;;
    -c | --create )         conda_create
                            exit
                            ;;
    -i | --install )        conda_install
                            exit
                            ;;
    -id | --install_dev )   conda_install_dev
                            exit
                            ;;
    -l | --list )           conda info --envs
                            exit
                            ;;
    -r | --remove )         conda_remove
                            exit
                            ;;
    -h | --help )           conda_usage
                            exit
                            ;;
    * )                     conda_usage
                            exit 1
