#!/bin/sh
arch=$(dpkg --print-architecture)
apt-get install -y --no-install-recommends x11vnc xvfb
curl -fSL "https://github.com/TurboVNC/turbovnc/releases/download/3.3/turbovnc_3.3_${arch}.deb" -o /tmp/turbovnc.deb
apt-get install -y /tmp/turbovnc.deb && rm /tmp/turbovnc.deb
apt-get install -y --no-install-recommends python3-numpy
git clone --depth 1 "https://github.com/novnc/noVNC.git" /opt/novnc
git clone --depth 1 "https://github.com/novnc/websockify.git" /opt/novnc/utils/websockify

cat > /usr/bin/xstartup.turbovnc << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
xfce4-session
EOF
chmod +x /usr/bin/xstartup.turbovnc
mkdir -p /etc/turbovnc
ln -s /usr/bin/xstartup.turbovnc /etc/turbovnc/xstartup
