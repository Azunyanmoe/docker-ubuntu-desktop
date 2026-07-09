#!/bin/sh
echo "[novnc] starting TurboVNC..."
export DISPLAY=:1
/opt/TurboVNC/bin/vncserver :1 -geometry 1920x1080 -depth 24 -localhost no 2>&1
if [ $? -eq 0 ]; then
    echo "[novnc] TurboVNC started on :1 (port 5901)"
else
    echo "[novnc] TurboVNC FAILED"
fi
echo "[novnc] starting noVNC proxy..."
/opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 2>&1
