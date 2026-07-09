#!/bin/sh
arch=$(dpkg --print-architecture)
if [ "${arch}" = "amd64" ] ; then
	curl -fSL "https://web9001.nomachine.com/download/9.7/Linux/nomachine_9.7.3_1_amd64.deb" -o nomachine.deb
	dpkg -i nomachine.deb
	rm nomachine.deb
	groupmod -g 2000 nx
	sed -i "s|#EnableClipboard both|EnableClipboard both|g" /usr/NX/etc/server.cfg
	sed -i '/DefaultDesktopCommand/c\DefaultDesktopCommand "xset s off && /usr/bin/startxfce4"' /usr/NX/etc/node.cfg
fi
