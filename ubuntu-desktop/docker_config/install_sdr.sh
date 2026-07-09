#!/bin/bash
set -e
arch=$(dpkg --print-architecture)

# Remote Desktop Tools
bash /docker_config/install_nomachine.sh
bash /docker_config/install_kasmvnc.sh
bash /docker_config/install_novnc.sh

# ungoogled-chromium
add-apt-repository -y ppa:xtradeb/apps
apt-get install -y --no-install-recommends chromium
update-alternatives --set x-www-browser /usr/bin/chromium

cat > /usr/local/bin/chromium << 'EOF'
#!/bin/sh
exec /usr/bin/chromium --no-sandbox "$@"
EOF
chmod +x /usr/local/bin/chromium
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/bin/chromium 100

# SDR++ nightly .deb
SDRPP_DEB="sdrpp_debian_sid_${arch}.deb"
[ "$arch" = "amd64" ] && SDRPP_DEB="sdrpp_debian_sid_amd64.deb"
[ "$arch" = "arm64" ] && SDRPP_DEB="sdrpp_debian_sid_aarch64.deb"
curl -fSL "https://github.com/AlexandreRouma/SDRPlusPlus/releases/download/nightly/${SDRPP_DEB}" -o /tmp/sdrpp.deb
apt-get install -y /tmp/sdrpp.deb && rm /tmp/sdrpp.deb

for f in /usr/lib/$(dpkg --print-architecture)-linux-gnu/libvolk.so.3.*; do
    if [ -f "$f" ]; then
        ln -sf "$f" "$(dirname "$f")/libvolk.so.3.3"
    fi
done
ldconfig

# GridTracker2 .deb
GT_DEB="GridTracker2-2.260701.1-${arch}.deb"
[ "$arch" = "amd64" ] && GT_DEB="GridTracker2-2.260701.1-amd64.deb"
[ "$arch" = "arm64" ] && GT_DEB="GridTracker2-2.260701.1-arm64.deb"
curl -fSL "https://download2.gridtracker.org/${GT_DEB}" -o /tmp/gt.deb
apt-get install -y /tmp/gt.deb && rm /tmp/gt.deb

# SDRangel v7.25.1 .deb (x86_64 only)
if [ "$arch" = "amd64" ]; then
    curl -fSL "https://github.com/f4exb/sdrangel/releases/download/v7.25.1/sdrangel_7.25.1_ubuntu-24.04_amd64.deb" -o /tmp/sdrangel.deb
    apt-get install -y /tmp/sdrangel.deb && rm /tmp/sdrangel.deb
fi

# gpredict + wfview
apt-get install -y --no-install-recommends gpredict wfview

# SDRplay API v3.15.2
curl -fSL "https://www.sdrplay.com/software/SDRplay_RSP_API-Linux-3.15.2.run" -o /tmp/sdrplay.run
chmod +x /tmp/sdrplay.run
mkdir -p /tmp/sdrplay_installer
echo "extracting SDRplay API..."
/tmp/sdrplay.run --noexec --target /tmp/sdrplay_installer 2>&1 || true
if [ -z "$(ls -A /tmp/sdrplay_installer 2>/dev/null)" ]; then
    echo "trying --tar extraction..."
    /tmp/sdrplay.run --tar -xzf -C /tmp/sdrplay_installer 2>&1 || true
fi
if [ -z "$(ls -A /tmp/sdrplay_installer 2>/dev/null)" ]; then
    echo "trying manual payload extraction..."
    SKIP=$(grep -abm1 'BZh' /tmp/sdrplay.run | cut -d: -f1)
    [ -n "$SKIP" ] && tail -c +$SKIP /tmp/sdrplay.run | tar xzf - -C /tmp/sdrplay_installer 2>&1 || true
fi
echo "SDRplay extracted files:"
find /tmp/sdrplay_installer -type f | head -50
ARCH=$(dpkg --print-architecture)
echo "installing SDRplay API for arch: ${ARCH}"
mkdir -p /usr/local/lib /usr/local/include /opt/sdrplay_api /etc/udev/rules.d /etc/udev/hwdb.d
cp -f /tmp/sdrplay_installer/${ARCH}/libsdrplay_api.so.3.15 /usr/local/lib/
chmod 644 /usr/local/lib/libsdrplay_api.so.3.15
ln -sf libsdrplay_api.so.3.15 /usr/local/lib/libsdrplay_api.so.3
ln -sf libsdrplay_api.so.3   /usr/local/lib/libsdrplay_api.so
cp -f /tmp/sdrplay_installer/inc/sdrplay_api*.h /usr/local/include/
chmod 644 /usr/local/include/sdrplay_api*.h
cp -f /tmp/sdrplay_installer/${ARCH}/sdrplay_apiService /opt/sdrplay_api/
chmod 755 /opt/sdrplay_api/sdrplay_apiService
cat > /etc/udev/rules.d/66-sdrplay.rules << 'RULES'
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="2500",MODE:="0666"
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="3000",MODE:="0666"
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="3010",MODE:="0666"
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="3020",MODE:="0666"
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="3030",MODE:="0666"
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="3050",MODE:="0666"
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="3060",MODE:="0666"
RULES
chmod 644 /etc/udev/rules.d/66-sdrplay.rules
cat > /etc/udev/hwdb.d/20-sdrplay.hwdb << 'HWDB'
usb:v1DF7*
 ID_VENDOR_FROM_DATABASE=SDRplay

usb:v1DF7p2500*
 ID_MODEL_FROM_DATABASE=RSP1

usb:v1DF7p3000*
 ID_MODEL_FROM_DATABASE=RSP1A

usb:v1DF7p3010*
 ID_MODEL_FROM_DATABASE=RSP2/RSP2pro

usb:v1DF7p3020*
 ID_MODEL_FROM_DATABASE=RSPduo

usb:v1DF7p3030*
 ID_MODEL_FROM_DATABASE=RSPdx

usb:v1DF7p3050*
 ID_MODEL_FROM_DATABASE=RSP1B

usb:v1DF7p3060*
 ID_MODEL_FROM_DATABASE=RSPdxR2
HWDB
chmod 644 /etc/udev/hwdb.d/20-sdrplay.hwdb
ldconfig
rm -rf /tmp/sdrplay.run /tmp/sdrplay_installer

# SoapySDRPlay3 (for SatDump, SDRangel, etc.)
apt-get install -y --no-install-recommends libsoapysdr-dev soapysdr-tools
git clone --depth 1 "https://github.com/pothosware/SoapySDRPlay3.git" /tmp/SoapySDRPlay3
mkdir -p /tmp/SoapySDRPlay3/build && cd /tmp/SoapySDRPlay3/build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc) && make install
cd / && rm -rf /tmp/SoapySDRPlay3
apt-get remove --purge -y libsoapysdr-dev

rm -rf /var/lib/apt/lists/*
