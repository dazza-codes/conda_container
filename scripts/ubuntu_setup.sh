#!/usr/bin/env bash

sudo apt-get update -yq
sudo apt-get install -yq \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    build-essential \
    g++ \
    gfortran \
    git \
    cmake \
    make \
    ca-certificates \
    openssh-client \
    openssl \
    software-properties-common

ls /etc/ssl/certs/ca-certificates.crt 
sudo update-ca-certificates
export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
git config --global http.sslVerify true
git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt
git config --global http.sslBackend "gnutls"

cat /etc/lsb-release 
ssh-keygen -o -t rsa -b 4096 -f ~/.ssh/gitlab_id_rsa
ssh-keygen -o -t rsa -b 4096 -f ~/.ssh/github_id_rsa
cat ~/.ssh/gitlab_id_rsa.pub
cat ~/.ssh/github_id_rsa.pub

sudo update-alternatives --config editor
#vim ~/.gitconfig
#vim ~/.bashrc
mkdir bin
mkdir src
cd src/
git clone git@github.com:dazza-codes/conda_container.git
source conda_container/conda_venv.sh 
sudo mkdir /opt/conda
sudo chown -R $USER:$USER /opt
conda-install  # enter /opt/conda as install path
#vim ~/.bashrc 
conda --version
conda-venv-py36
conda-venv-py37
conda-venv-py38
conda env list

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
cat /etc/lsb-release 
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get -y update
sudo apt-cache policy docker-ce
sudo apt-get -y install docker-ce 
sudo apt-get -y install gnupg2 pass
sudo groupadd docker
sudo usermod -aG docker $USER
echo $USER

docker login registry.gitlab.com
docker run hello-world
which tmux

curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
which poetry

curl -o jq-linux64 -sSL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
sudo mv jq-linux64 /usr/local/bin/jq
sudo chmod a+x /usr/local/bin/jq
jq --version

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

