#!/bin/bash
set -e

BUILD_DEPS="\
    build-essential \
    gfortran \
    make cmake \
    ccache \
    unzip \
    git \
    ca-certificates curl \
    libfftw3-dev libpng-dev libtiff-dev libjemalloc-dev \
    libcurl4-openssl-dev libsqlite3-dev libvolk-dev libnng-dev \
    libglfw3-dev libdbus-1-dev portaudio19-dev libzstd-dev libhdf5-dev librtaudio-dev \
    libxrandr-dev \
    librtlsdr-dev libhackrf-dev libairspy-dev libairspyhf-dev \
    libad9361-dev libiio-dev libbladerf-dev libomp-dev \
    ocl-icd-opencl-dev intel-opencl-icd mesa-opencl-icd libarmadillo-dev \
    libboost-log-dev libboost-thread-dev libboost-system-dev \
    libhamlib-dev libusb-1.0-0-dev libudev-dev \
    qtbase5-dev qtmultimedia5-dev qttools5-dev qttools5-dev-tools \
    libqt5serialport5-dev libqt5websockets5-dev libqt5opengl5-dev"

apt-get update
apt-get install -y --no-install-recommends $BUILD_DEPS
apt-get install -y --no-install-recommends libhamlib-utils
# Keep apt lists for build_sdr.sh's apt-cache depends resolution
