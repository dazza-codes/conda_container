FROM continuumio/miniconda3
LABEL maintainers="Darren Weber <dweber.consulting@gmail.com>"
LABEL version="0.1.0"

SHELL ["/bin/bash", "-c"]

USER root

# check that continuumio/miniconda3 has provided the global conda init for bash
RUN if ! test -f /etc/profile.d/conda.sh; then \
        mkdir -p /etc/profile.d && \
        ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh; \
    fi

RUN conda update -n base conda

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
    chown -R joe:joe $HOME
USER joe

# WORKDIR does not respect USER, so first mkdir with USER permissions
ENV CONDA_ENV app
RUN mkdir ${HOME}/app 
WORKDIR ${HOME}/app
COPY --chown=joe:joe conda*.sh environment.yml requirements.txt ./

RUN source /opt/conda/etc/profile.d/conda.sh && \
    source ./conda_venv.sh && \
    conda-venv && \
    conda env update -n ${CONDA_ENV} --file environment.yml && \
    pip install -U -r requirements.txt && \
    conda clean -a -y -q

RUN echo "conda activate ${CONDA_ENV}" >> ${HOME}/.bashrc
CMD /bin/bash -l
