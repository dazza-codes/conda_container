#!/bin/bash

#
# This script is NOT a replacement for using 'conda' directly; the purpose of
# this script is for automation system to (a) discover where the 'conda' command
# is or find some way to enable it and (b) then use it to manage a conda
# environment.
#


set -e

test -z "$CONDA_ENV" && export CONDA_ENV="conda-tmp-env"

source ./conda_funcs.sh

CONDA_FOUND=false

if _conda3_is_function; then
    CONDA_FOUND=true
elif which conda > /dev/null 2>&1; then
    CONDA_FOUND=true
elif _conda3_init; then
    CONDA_FOUND=true
fi

if ! $CONDA_FOUND; then
    echo "WARNING: did not find miniconda3 or anaconda3 'conda' command"
fi


_conda3_env_usage() {
    cat <<- USAGE
usage: $0 [option]

options:
-a  | --activate        info about 'conda activate $CONDA_ENV'
-d  | --deactivate      info about 'conda deactivate'
-c  | --create          create $CONDA_ENV
-i  | --install         install $CONDA_ENV with requirements.txt
-id | --install_dev     install $CONDA_ENV plus requirements.dev
-l  | --list            conda env list
-r  | --remove          remove $CONDA_ENV
-h  | --help
USAGE
}

case $1 in
    -a | --activate )       _conda3_env_echo_activate
                            exit
                            ;;
    -d | --deactivate )     _conda3_env_echo_deactivate
                            exit
                            ;;
    -c | --create )         _conda3_env_create
                            exit
                            ;;
    -i | --install )        _conda3_env_install
                            exit
                            ;;
    -id | --install_dev )   _conda3_env_install_dev
                            exit
                            ;;
    -l | --list )           conda info --envs
                            exit
                            ;;
    -r | --remove )         _conda3_env_remove
                            exit
                            ;;
    -h | --help )           _conda3_env_usage
                            exit
                            ;;
    * )                     _conda3_env_usage
                            exit 1
esac
