#!/bin/sh
echo "[nomachine] starting NoMachine server..."
/etc/NX/nxserver --startup 2>&1
echo "[nomachine] NoMachine started (or already running)"
tail -f /usr/NX/var/log/*.log 2>/dev/null || tail -f /dev/null
