#!/bin/sh
echo "[kasmvnc] starting KasmVNC..."
export DISPLAY=:1

# Set password for KasmVNC
if [ ! -f "/home/$USER/.vnc/passwd" ]; then
    su $USER -c "echo -e \"$PASSWORD\n$PASSWORD\n\" | kasmvncpasswd -u $USER -o -w -r"
fi

# Clean up lock files
rm -rf /tmp/.X1000-lock /tmp/.X11-unix/X1000

# Start KasmVNC as user
if [ ! -z ${DISABLE_HTTPS+x} ]; then
    su $USER -c "kasmvncserver :1000 -select-de xfce -interface 0.0.0.0 -websocketPort 4000 -sslOnly 0 -RectThreads 2"
else
    su $USER -c "kasmvncserver :1000 -select-de xfce -interface 0.0.0.0 -websocketPort 4000 -cert /etc/ssl/certs/ssl-cert-snakeoil.pem -key /etc/ssl/private/ssl-cert-snakeoil.key -RectThreads 2"
fi

su $USER -c "pulseaudio --start" 2>/dev/null || true
tail -f /home/$USER/.vnc/*.log
