
# Private Dependencies

## Docker builds with private dependencies

The docker builds can use an --ssh option that depends on the user having an ssh agent running.
The following lines can be added to a ~/.bashrc or ~/.bash_profile:

```
eval $(ssh-agent -s)
ssh-add ~/.ssh/gitlab_rsa
```

Then a `Makefile` rule can use the `--ssh` option, e.g.
```
build:
	DOCKER_BUILDKIT=1 docker build -t $(IMAGE) \
		--ssh default=$${SSH_AUTH_SOCK} \
		--ssh gitlab=$${HOME}/.ssh/gitlab_rsa \
		.
```

#### Dockerfile for private dependencies

```
#
# The aim of the following is for a USER to create and own a CONDA_ENV.
# The following was tested with conda 4.5.12, which installed the
# CONDA_ENV into $HOME/.conda/env/$CONDA_ENV for the USER, with
# the correct permissions for the USER.
#

ENV HOME /home/joe

RUN userdel -rf joe 2> /dev/null || true && \
    groupadd -rf --gid 1000 joe && \
    useradd --no-log-init --system --create-home --gid joe --uid 1000 joe && \
    chown -R joe:joe "${HOME}"

#
# Install the app code using a CONDA_ENV and the USER; note that only
# COPY and RUN respect the USER and check that --chown options are used
# for COPY.
#

USER joe

ENV CONDA_ENV app
ENV APP_PATH "${HOME}/app"

# WORKDIR does not respect USER, so first mkdir with USER permissions
RUN mkdir "${APP_PATH}"
WORKDIR "${APP_PATH}"
COPY --chown=joe:joe conda*.sh environment.yml requirements.* ./

# Create and activate a new CONDA_ENV; this assumes that the
# /etc/profile.d/conda.sh exists and works as expected.
RUN source /etc/profile.d/conda.sh && \
    ./conda_setup.sh -c && \
    conda activate "${CONDA_ENV}" && \
    echo -e "\n\nconda activate ${CONDA_ENV}" >> "${HOME}/.bashrc"

# Install only public dependencies in the new CONDA_ENV.
RUN source /etc/profile.d/conda.sh && \
    conda activate "${CONDA_ENV}" && \
    ./conda_setup.sh -i && \
    conda clean -a -y -q

# Install private dependencies from gitlab repositories;
# it needs to use an ssh mount for access to gitlab.
RUN --mount=type=ssh,id=gitlab \
    mkdir -p "${HOME}/.ssh" && \
    touch "${HOME}/.ssh/known_hosts" && \
    ssh-keyscan gitlab.com >> "${HOME}/.ssh/known_hosts"

# For this step, the ssh-agent is exposed to the parent SHELL of the RUN
# command, so all the conda/pip commands that require git+ssh access to private
# repositories must be run within the parent SHELL (no bash scripts can be used
# to encapsulate conda or pip commands because they cannot access the ssh
# credentials properly).  Note that this sources conda_funcs.sh
RUN --mount=type=ssh,id=gitlab \
    source ./conda_funcs.sh && \
    _conda3_env && \
    _conda3_init && \
    conda activate "${CONDA_ENV}" && \
    _conda3_env_pip_install && \
    conda clean -a -y -q
```

