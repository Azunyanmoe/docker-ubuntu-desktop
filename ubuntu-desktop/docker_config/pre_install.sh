#!/bin/sh
set -e

apt-get update
apt-get install -y --no-install-recommends \
    sudo vim locales gnupg2 wget curl zip lsb-release bash-completion \
    net-tools iputils-ping mesa-utils software-properties-common build-essential \
    python3 python3-pip python3-numpy \
    openssh-server openssl git git-lfs tmux

rm -rf /var/lib/apt/lists/*
