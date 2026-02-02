#!/bin/bash
set -e

echo "========================================"
echo "Ubuntu Desktop - Starting"
echo "========================================"

# SSH - create required directory
mkdir -p /var/run/sshd
/usr/sbin/sshd

# KasmVNC - create user config directory and set up
mkdir -p /home/${USER}/.vnc
chown -R ${USER}:${USER} /home/${USER}/.vnc

# Create KasmVNC password file (KasmVNC uses echo with newlines)
su - ${USER} -c "echo -e '${VNC_PASSWORD}\n${VNC_PASSWORD}' | vncpasswd -u ${USER} -w"

# Start KasmVNC with display :1 (non-interactive)
su - ${USER} -c "DISPLAY=:1 vncserver :1 -localhost no -cert none -plainport 6901 -depth 24 -geometry 1920x1080" || true

echo "========================================"
echo "Ready!"
echo "========================================"
echo "SSH:     ssh ${USER}@localhost -p 22"
echo "Web:     https://localhost:6901"
echo "User:    ${USER}"
echo "Password: ${PASSWORD}"
echo "========================================"

tail -f /dev/null
