#!/bin/bash

#
# This set of bash functions is NOT a replacement for using 'conda' directly;
# the purpose of these functions is for an automation system to (a) discover
# where the 'conda' command is or source the right setup to enable it or install
# miniconda3 and (b) then use it to work with a conda environment named by
# $CONDA_ENV.
#

_conda3_env() {
    test -z "$CONDA_ENV" && test -f environment.yml && \
        export CONDA_ENV=$(grep 'name:' environment.yml | sed -e 's/name:[ ]*//g')

    test -z "$CONDA_ENV" && test -f .env && \
        export CONDA_ENV=$(grep -e '^CONDA_ENV=.*' .env | cut -d '=' -f2)

    test -z "$CONDA_ENV" && \
        export CONDA_ENV=$(basename $(pwd))

    if test -n "$CONDA_ENV"; then
        echo -e "INFO:\tUsing conda env: ${CONDA_ENV}"
        return 0
    else
        echo "WARNING: failed to init CONDA_ENV"
        return 1
    fi
}

_conda3_init() {
    test -n "${DEBUG}" && echo "DEBUG: in _conda3_init"
    if _conda3_is_function; then
        # nothing to do, some form of conda init is active
        return 0
    fi
    # Search for a conda.sh init script for bash.
    # Only use pyenv as a last resort to manage miniconda3-latest;
    # see https://github.com/pyenv/pyenv/issues/1112
    if _conda3_find_miniconda3; then
        echo -e "INFO:\tFound miniconda3 installed (outside pyenv)"
        source ${CONDA_SH} && return 0
    elif _conda3_find_anaconda3; then
        echo -e "INFO:\tFound anaconda3 installed (outside pyenv)"
        source ${CONDA_SH} && return 0
    elif _conda3_find_pyenv_miniconda3; then
        echo -e "INFO:\tFound miniconda3 installed (using pyenv)"
        source ${CONDA_SH} && return 0
    elif _conda3_install_miniconda3; then
        _conda3_find_miniconda3 && \
        source ${CONDA_SH} && return 0
    else
        test -n "${DEBUG}" && echo "DEBUG: failed to init conda"
        return 1
    fi
}


#
# Find conda
#

_conda3_is_function() {
    test -n "${DEBUG}" && echo "DEBUG: in _conda3_is_function"
    if type conda > /dev/null 2>&1; then
        conda_type=$(type -t conda)
        if [[ "${conda_type}" == "function" ]]; then
            test -n "${DEBUG}" && echo "DEBUG: conda is a function"
            return 0
        fi
    fi
    test -n "${DEBUG}" && echo "DEBUG: conda is not a function"
    return 1
}

_conda3_find() {
    conda3_sh=$1
    test -n "${DEBUG}" && echo "DEBUG: in _conda3_find for $conda3_sh"
    if test -f "${HOME}${conda3_sh}"; then
        export CONDA_SH="${HOME}${conda3_sh}"
    elif test -f /opt/${conda3_sh}; then
        export CONDA_SH="/opt/${conda3_sh}"
    elif test -f ${conda3_sh}; then
        export CONDA_SH="${conda3_sh}"
    fi

    if test -n "${CONDA_SH}"; then
        test -n "${DEBUG}" && echo "DEBUG: found $CONDA_SH"
        return 0
    else
        test -n "${DEBUG}" && echo "DEBUG: failed to find $CONDA_SH"
        return 1
    fi
}


# Note: pyenv does not have an anaconda3-latest install candidate
#_conda3_find_pyenv_anaconda3() {
#    _conda3_find "${HOME}/.pyenv/versions/anaconda3-latest/etc/profile.d/conda.sh"
#}

_conda3_find_anaconda3() {
    _conda3_find "/anaconda3/etc/profile.d/conda.sh"
}

_conda3_find_miniconda3() {
    _conda3_find "/miniconda3/etc/profile.d/conda.sh"
}

_conda3_find_pyenv_miniconda3() {
    _conda3_find "${HOME}/.pyenv/versions/miniconda3-latest/etc/profile.d/conda.sh"
}

#
# Install miniconda3 and update it
#

_conda3_update() {
    conda update --yes -n base -c defaults conda
}

_conda3_install_miniconda3() {
    echo -e "INFO:\tInstalling miniconda3"
    # Use a direct download and install for miniconda3, rather than a
    # pyenv installation; see https://github.com/pyenv/pyenv/issues/1112
    _conda3_install_miniconda3_direct
}

_conda3_install_miniconda3_direct() {
    test -n "${DEBUG}" && echo "DEBUG: in _conda3_install_miniconda3_direct"
    if uname -a | grep -q -E 'x86_64 GNU/Linux'; then
        curl -s -L -o miniconda_installer.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        bash miniconda_installer.sh
        rm miniconda_installer.sh
    elif uname -a | grep -q -E 'Darwin Kernel .*x86_64'; then
        curl -s -L -o miniconda_installer.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
        bash miniconda_installer.sh
        rm miniconda_installer.sh
    else
        echo "Unknown system requirements, use a manual install; see"
        echo "https://conda.io/en/latest/miniconda.html"
        return 1
    fi
}

_conda3_pyenv_init() {
    test -n "${DEBUG}" && echo "DEBUG: in _conda3_pyenv_init"
    if command -v pyenv > /dev/null 2>&1; then
        test -n "${DEBUG}" && echo "DEBUG: https://github.com/pyenv/pyenv is installed and activated"
    else
        _conda3_pyenv_install
    fi
    # To make immediate use of pyenv in this SHELL, initialize it.
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
}

_conda3_pyenv_install() {
    test -n "${DEBUG}" && echo "DEBUG: in _conda3_pyenv_install"
    if test -f ${HOME}/.pyenv; then
        test -n "${DEBUG}" && echo "DEBUG: https://github.com/pyenv/pyenv is installed in ${HOME}/.pyenv"
    else
        echo "https://github.com/pyenv/pyenv will be installed in ${HOME}/.pyenv"
        git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ${HOME}/.bash_profile
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ${HOME}/.bash_profile
        echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ${HOME}/.bash_profile
    fi
}

_conda3_pyenv_install_miniconda3() {
    _conda3_pyenv_init
    test -n "${DEBUG}" && echo "DEBUG: in _conda3_pyenv_install_miniconda3"
    if pyenv versions | grep -q miniconda3-latest; then
        test -n "${DEBUG}" && echo "DEBUG: https://github.com/pyenv/pyenv installed miniconda3-latest"
    else
        echo "https://github.com/pyenv/pyenv will install miniconda3-latest"
        pyenv install miniconda3-latest
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
    if conda info --envs | grep -q "envs/${CONDA_ENV}$"; then
        return 0
    else
        echo -e "\nconda env does not exist: ${CONDA_ENV}\n"
        return 1
    fi
}

_conda3_env_is_active() {
    # assumes the active conda env is tagged by an '*'.
    if conda info --envs | grep -q -E "^${CONDA_ENV}.*[*]+"; then
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
        conda clean -a -y -q
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
    if test -f environment.yml; then
        echo "Using conda to update ${CONDA_ENV} with environment.yml"
        conda env update --name ${CONDA_ENV} --file environment.yml
        conda clean -a -y -q
    fi
}

_conda3_env_pip() {
    # Use pip to add packages to an active CONDA_ENV
    requirements_file=$1
    if test -f ${requirements_file}; then
        if _conda3_env_exists && _conda3_env_is_active; then
            echo "Using pip to install ${CONDA_ENV} ${requirements_file}"
            pip install -r ${requirements_file}
        fi
    else
        echo "There is no ${requirements_file} file"
    fi
}

_conda3_env_pip_install() {
    _conda3_env_pip requirements.txt
}

_conda3_env_pip_install_dev() {
    _conda3_env_pip requirements.dev
}

_conda3_env_remove() {
    conda env remove --name ${CONDA_ENV}
}

