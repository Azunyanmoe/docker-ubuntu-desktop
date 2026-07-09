#!/bin/sh
## initialize environment
if [ ! -f "/docker_config/init_flag" ]; then
    # set python is python3
    update-alternatives --install /usr/bin/python python /usr/bin/python3 2
    # update /etc/environment
    export PATH=/usr/NX/scripts/vgl:$PATH
    env | grep -Ev "CMD=|PWD=|SHLVL=|_=|DEBIAN_FRONTEND=|USER=|HOME=|UID=|GID=|PASSWORD=" > /etc/environment
    # create user
    if id "$UID" >/dev/null 2>&1; then
        EXISTING_USER=$(id -nu "$UID")
        echo "user with UID $UID already exists as '$EXISTING_USER', reusing it"
        USER=$EXISTING_USER
    else
        if ! getent group "$GID" >/dev/null 2>&1; then
            groupadd -g "$GID" "$USER"
        fi
        useradd --create-home --no-log-init -u "$UID" -g "$GID" "$USER"
        usermod -aG sudo "$USER"
        usermod -aG ssl-cert "$USER"
    fi
    # docker socket support
    if [ -S /var/run/docker.sock ]; then
        DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
        if ! getent group $DOCKER_GID > /dev/null 2>&1; then
            groupadd -g $DOCKER_GID docker
        fi
        DOCKER_GROUP=$(getent group $DOCKER_GID | cut -d: -f1)
        usermod -aG $DOCKER_GROUP $USER
    fi
    # password
    echo "root:$PASSWORD" | chpasswd
    echo "$USER:$PASSWORD" | chpasswd
    chsh -s /bin/bash $USER
    # /run/user/$UID
    mkdir -p /run/user/$UID
    chown $GID:$UID /run/user/$UID
    # extra env init for developer
    if [ -f "/docker_config/env_init.sh" ]; then
        bash /docker_config/env_init.sh
    fi
    # custom env init for user
    if [ -f "/docker_config/custom_env_init.sh" ]; then
        bash /docker_config/custom_env_init.sh
    fi
    echo  "ok" > /docker_config/init_flag
fi
## startup
# diagnostics
echo "=== desktop diagnostics ==="
echo "DISPLAY=$DISPLAY"
echo "REMOTE_DESKTOP=$REMOTE_DESKTOP"
echo "xfce4-session: $(which xfce4-session 2>&1 || echo 'NOT FOUND')"
echo "xfce.desktop: $(ls /usr/share/xsessions/xfce.desktop 2>&1 || echo 'NOT FOUND')"
echo "Xvnc: $(which Xvnc 2>&1 || echo 'NOT FOUND')"
echo "dbus socket: $(test -S /var/run/dbus/system_bus_socket && echo 'OK' || echo 'NOT FOUND')"
echo "==========================="

# start dbus (required by Xfce4)
dbus-uuidgen --ensure
if [ ! -S /var/run/dbus/system_bus_socket ]; then
    mkdir -p /var/run/dbus
    dbus-daemon --system --fork
    sleep 0.5
    if [ -S /var/run/dbus/system_bus_socket ]; then
        echo "[entrypoint] dbus-daemon started"
    else
        echo "[entrypoint] dbus-daemon FAILED - socket not created"
    fi
fi
# custom startup for user
if [ -f "/docker_config/custom_startup.sh" ]; then
	bash /docker_config/custom_startup.sh
fi
# start sshd
/usr/sbin/sshd
# start sdrplay api service
if [ -x /opt/sdrplay_api/sdrplay_apiService ]; then
    /opt/sdrplay_api/sdrplay_apiService &
fi
# start remote desktop
if [ "${REMOTE_DESKTOP}" = "nomachine" ]; then
    echo "start nomachine"
    bash /docker_config/start_nomachine.sh
elif [ "${REMOTE_DESKTOP}" = "kasmvnc" ]; then
    echo "start kasmvnc"
    bash /docker_config/start_kasmvnc.sh
elif [ "${REMOTE_DESKTOP}" = "novnc" ]; then
    echo "start novnc"
    bash /docker_config/start_novnc.sh
else
    echo  "unspported remote desktop: $REMOTE_DESKTOP"
fi
