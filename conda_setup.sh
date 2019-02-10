#!/bin/bash

#
# This script is NOT a replacement for using 'conda' directly; the purpose of
# this script is for automation system to (a) discover where the 'conda' command
# is or find some way to enable it and (b) then use it to manage a conda
# environment.
#


set -e

test -z "$CONDA_ENV" && test -f environment.yml && \
    export CONDA_ENV=$(grep 'name:' environment.yml | sed -e 's/name:[ ]*//g')

test -z "$CONDA_ENV" && \
    export CONDA_ENV=$(basename $(pwd))

echo -e "\nUsing conda env: ${CONDA_ENV}\n"

source ./conda_funcs.sh

_conda3_init

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
-a   | --activate        info about 'conda activate $CONDA_ENV'
-d   | --deactivate      info about 'conda deactivate'
-c   | --create          create $CONDA_ENV
-i   | --install         use conda to install environment.yml and/or requirements.txt
-id  | --install_dev     use conda to install requirements.dev
-ip  | --install_pip     use pip to install requirements.txt
-ipd | --install_pip_dev use pip to install requirements.dev
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
    -id | --install_dev )       _conda3_env_install_dev
                                exit
                                ;;
    -ip | --install_pip )       _conda3_env_activate && _conda3_env_pip_install
                                exit
                                ;;
    -ipd | --install_pip_dev )  _conda3_env_activate && _conda3_env_pip_install_dev
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
