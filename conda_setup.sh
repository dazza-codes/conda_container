#!/bin/bash

#
# This script is NOT a replacement for using 'conda' directly; the purpose of
# this script is for automation system to (a) discover where the 'conda' command
# is or find some way to install and enable it and (b) then use it to manage a
# conda environment.
#

set -e


test -z "$CONDA_ENV" && test -f environment.yml && \
    export CONDA_ENV=$(grep 'name:' environment.yml | sed -e 's/name:[ ]*//g')

test -z "$CONDA_ENV" && test -f .env && \
    export CONDA_ENV=$(grep -e '^CONDA_ENV=.*' .env | cut -d '=' -f2)

test -z "$CONDA_ENV" && \
    export CONDA_ENV=$(basename $(pwd))

echo -e "\nUsing conda env: ${CONDA_ENV}\n"

source ./conda_funcs.sh

_conda3_init

if type conda; then
    echo
else
    echo "WARNING: did not find 'conda' command"
    echo
fi


_conda3_env_usage() {
    cat <<- USAGE
usage: $0 [option]

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
