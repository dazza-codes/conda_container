#!/bin/bash

# Copyright 2019-2020 Darren Weber
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This set of bash functions is NOT a replacement for using 'conda' directly;
# the purpose of these functions is for an automation system to (a) discover
# where the 'conda' command is or source the right setup to enable it or install
# miniconda3 and (b) then use it to work with a conda environment named by
# $CONDA_ENV.

#
# Find conda
#

_conda3_is_function() {
    if type conda > /dev/null 2>&1; then
        conda_type=$(type -t conda)
        if [[ "${conda_type}" == "function" ]]; then
            return 0
        fi
    fi
    return 1
}

_conda3_find() {
    conda3_sh=$1
    if test -f "${HOME}${conda3_sh}"; then
        export CONDA_SH="${HOME}${conda3_sh}"
        return 0
    elif test -f /opt/${conda3_sh}; then
        export CONDA_SH="/opt/${conda3_sh}"
        return 0
    elif test -f ${conda3_sh}; then
        export CONDA_SH="${conda3_sh}"
        return 0
    else
        return 1
    fi
}

_conda3_find_miniconda3() {
    _conda3_find "/miniconda3/etc/profile.d/conda.sh"
}

_conda3_find_anaconda3() {
    _conda3_find "/anaconda3/etc/profile.d/conda.sh"
}

_conda3_init() {
    if _conda3_is_function; then
        # nothing to do, init is done
        return 0
    elif _conda3_find_miniconda3 || _conda3_find_anaconda3; then
        source ${CONDA_SH} && return 0
    elif _conda3_install_miniconda3 && _conda3_find_miniconda3; then
        source ${CONDA_SH} && return 0
    else
        return 1
    fi
}


#
# Install miniconda3 and update it
#

_conda3_update() {
    conda update --yes -n base -c defaults conda
}

_conda3_install_miniconda3() {
    if uname -a | grep -q -E 'x86_64 GNU/Linux'; then
        curl -s -L -o miniconda_installer.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        bash miniconda_installer.sh
        rm miniconda_installer.sh
        _conda3_update
    elif uname -a | grep -q -E 'Darwin Kernel .*x86_64'; then
        curl -s -L -o miniconda_installer.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
        bash miniconda_installer.sh
        rm miniconda_installer.sh
        _conda3_update
    else
        echo "Unknown system requirements, use a manual install; see"
        echo "https://conda.io/en/latest/miniconda.html"
        return 1
    fi
}


#
# Functions for a CONDA_ENV
#

_conda3_env_echo_activate() {
    echo "\
#
# To activate this environment, use
#
#     $ conda activate ${CONDA_ENV}
#"
}

_conda3_env_echo_deactivate() {
    echo "\
#
# To deactivate an active environment, use
#
#     $ conda deactivate
#"
}

_conda3_env_exists() {
    if conda info --envs | grep -q "${CONDA_ENV}"; then
        return 0
    else
        echo -e "\nERROR: conda env does not exist: ${CONDA_ENV}\n"
        return 1
    fi
}

_conda3_env_is_active() {
    # assumes the active conda env is tagged by an '*'.
    if conda info --envs | grep -q -E "${CONDA_ENV}.*[*]+"; then
        return 0
    else
        echo -e "\nERROR: conda env is not active: ${CONDA_ENV}\n"
	_conda3_env_echo_activate
        return 1
    fi
}

_conda3_env_create() {
    if ! _conda3_env_exists; then
        conda create --yes --name ${CONDA_ENV}
    fi
}


_conda3_env_activate() {
    if _conda3_env_exists; then
        conda activate ${CONDA_ENV}
    fi
}

_conda3_env_deactivate() {
    conda deactivate
}

_conda3_env_install() {
    _conda3_env_create
    echo "Install ${CONDA_ENV}"
    conda install --yes --name ${CONDA_ENV} \
        --channel conda-forge \
        --file requirements.txt
    conda clean -a -y -q
}

_conda3_env_install_dev() {
    _conda3_env_create
    echo "Install ${CONDA_ENV}"
    conda install --yes --name ${CONDA_ENV} \
        --channel conda-forge \
        --file requirements.txt \
        --file requirements.dev
    conda clean -a -y -q
}

_conda3_env_remove() {
    conda env remove --name ${CONDA_ENV}
}

