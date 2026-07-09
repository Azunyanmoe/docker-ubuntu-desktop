#!/bin/sh
arch=$(dpkg --print-architecture)
if [ "${arch}" = "amd64" ] ; then
	curl -fSL "https://github.com/kasmtech/KasmVNC/releases/download/v1.4.0/kasmvncserver_jammy_1.4.0_amd64.deb" -o kasmvnc.deb
	apt-get install -y ./kasmvnc.deb
	rm kasmvnc.deb
	# xfce4 is the default in KasmVNC's select-de.sh, no patch needed
fi
