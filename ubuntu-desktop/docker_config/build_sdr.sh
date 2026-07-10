#!/bin/bash
set -e
arch=$(dpkg --print-architecture)

BUILD_DEPS="\
    gfortran \
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

export CCACHE_DIR=/root/.ccache
export CCACHE_MAXSIZE=4G
ccache --zero-stats

git clone --depth 1 "https://github.com/SatDump/SatDump.git" /tmp/SatDump
mkdir -p /tmp/SatDump/build

curl -fSL "https://sourceforge.net/projects/wsjt-x-improved/files/WSJT-X_v3.1.0/Source%20code/wsjtx-3.1.0_improved_PLUS_260522.tgz/download" -o /tmp/wsjtx.tgz
cd /tmp && tar xzf wsjtx.tgz && rm wsjtx.tgz
mkdir -p /tmp/wsjtx-3.1.0/build

curl -fSL "https://sourceforge.net/projects/jtdx-improved/files/jtdx_2.2.159/Source%20code/jtdx_2.2.159_improved_source.zip/download" -o /tmp/jtdx.zip
cd /tmp && unzip -q jtdx.zip && rm jtdx.zip
mkdir -p /tmp/jtdx/build

(
  cd /tmp/SatDump/build
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache ..
  make -j$(nproc)
) &

(
  cd /tmp/wsjtx-3.1.0/build
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_Fortran_COMPILER_LAUNCHER=ccache \
    -DWSJT_SKIP_MANPAGES=ON -DWSJT_GENERATE_DOCS=OFF ..
  make -j$(nproc)
) &

(
  cd /tmp/jtdx/build
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_Fortran_COMPILER_LAUNCHER=ccache \
    -DWSJT_SKIP_MANPAGES=ON -DWSJT_GENERATE_DOCS=OFF ..
  make -j$(nproc)
) &

BUILD_FAIL=0
for job in $(jobs -p); do
  wait "$job" || BUILD_FAIL=1
done
if [ "$BUILD_FAIL" = 1 ]; then exit 1; fi

cd /tmp/SatDump/build && make install
cd / && rm -rf /tmp/SatDump

cd /tmp/wsjtx-3.1.0/build && make install
cd / && rm -rf /tmp/wsjtx*

cd /tmp/jtdx/build && make install
cd / && rm -rf /tmp/jtdx*

# ── Stage 1: ldd-detectable runtime deps ──
# For each resolved .so path, dpkg -S gives the owning package.
# When it returns a -dev package (unversioned symlink), resolve its
# runtime counterpart via apt-cache Depends.
find /usr/local -type f \( -executable -o -name '*.so*' \) | \
  xargs -r ldd 2>/dev/null | grep "=> /" | awk '{print $3}' | sort -u | \
  xargs -r dpkg -S 2>/dev/null | cut -d: -f1 | sort -u > /tmp/raw-runtime-deps.txt

# Keep non-dev packages directly, resolve -dev to their runtime deps
grep -v '\-dev' /tmp/raw-runtime-deps.txt > /docker_config/runtime-deps.txt

if grep -q '\-dev' /tmp/raw-runtime-deps.txt 2>/dev/null; then
  grep '\-dev' /tmp/raw-runtime-deps.txt | \
    xargs -r apt-cache depends 2>/dev/null | \
    grep "Depends:" | awk '{print $2}' | grep -v '\-dev' | \
    grep -E '^lib' >> /docker_config/runtime-deps.txt
fi
rm -f /tmp/raw-runtime-deps.txt

# ── Stage 2: deps invisible to ldd (dlopen, subprocess, etc.) ──
cat >> /docker_config/runtime-deps.txt << 'EOF'
intel-opencl-icd
mesa-opencl-icd
curl
EOF

sort -u -o /docker_config/runtime-deps.txt /docker_config/runtime-deps.txt

rm -rf /var/lib/apt/lists/*
