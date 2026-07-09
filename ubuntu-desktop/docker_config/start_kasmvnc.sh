#!/bin/sh
echo "[kasmvnc] starting KasmVNC..."
export DISPLAY=:1
export KASM_VNC_ENABLED=true
export KASM_VNC_PORT=4000

if [ -f /usr/share/xsessions/xfce.desktop ]; then
    echo "[kasmvnc] using xfce.desktop"
else
    echo "[kasmvnc] WARNING: xfce.desktop not found"
fi

/usr/lib/kasmvncserver/vncserver \
    -select-de /usr/share/xsessions/xfce.desktop \
    -geometry 1920x1080 \
    -depth 24 \
    -localhost no \
    -webserverPort 4000 \
    -cert /etc/ssl/certs/ssl-cert-snakeoil.pem \
    -key /etc/ssl/private/ssl-cert-snakeoil.key \
    -SecurityTypes TLSAuth \
    -UserParam webp_quality 100 \
    -UserParam disableBasicAuth false \
    -UserParam restrictPaste false \
    -UserParam restrictFileTransfer false 2>&1
