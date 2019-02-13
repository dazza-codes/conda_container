#!/bin/bash

#
# This script is NOT a replacement for using 'conda' directly; the purpose of
# this script is for automation system to (a) discover where the 'conda' command
# is or find some way to install and enable it and (b) then use it to manage a
# conda environment.
#

set -e

source ./conda_funcs.sh

_conda3_env
_conda3_init

if test -n "${DEBUG}"; then
    echo
    env | grep -i 'conda'
    echo
fi

if type conda >/dev/null 2>&1; then
    echo -e "INFO:\t$(conda --version)"
else
    echo "WARNING: did not find 'conda' command"
fi


_conda3_env_usage() {
    cat <<- USAGE

usage: $0 [option]

The options are all mutually exclusive.  The workflow to create a conda
environment and then install dependencies is as follows:

"""
export CONDA_ENV=conda_tmp      # a conda env --name
./conda_setup.sh -c             # create CONDA_ENV
conda activate \$CONDA_ENV       # do this manually, it's not automated
./conda_setup.sh -i             # install environment.yml (if present)
./conda_setup.sh -pi            # install requirements.txt (if present)
./conda_setup.sh -pd            # install requirements.dev (if present)
"""


options:
-a   | --activate        info about 'conda activate $CONDA_ENV'
-d   | --deactivate      info about 'conda deactivate'
-c   | --create          create $CONDA_ENV
-i   | --install         use conda to install environment.yml
-pi  | --pip_install     use pip to install requirements.txt
-pd  | --pip_install_dev use pip to install requirements.dev
-l   | --list            conda env list
-r   | --remove          remove $CONDA_ENV
-h   | --help

USAGE
}

case $1 in
    -a | --activate )           _conda3_env_echo_activate
                                exit
                                ;;
    -d | --deactivate )         _conda3_env_echo_deactivate
                                exit
                                ;;
    -c | --create )             _conda3_env_create
                                exit
                                ;;
    -i | --install )            _conda3_env_install
                                exit
                                ;;
    -pi | --pip_install )       _conda3_env_pip_install
                                exit
                                ;;
    -pd | --pip_install_dev )   _conda3_env_pip_install_dev
                                exit
                                ;;
    -l | --list )               conda info --envs
                                exit
                                ;;
    -r | --remove )             _conda3_env_remove
                                exit
                                ;;
    -h | --help )               _conda3_env_usage
                                exit
                                ;;
    * )                         _conda3_env_usage
                                exit 1
esac
