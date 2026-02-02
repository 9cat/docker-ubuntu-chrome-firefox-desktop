#!/bin/bash
set -e

echo "========================================"
echo "Ubuntu Desktop - Starting"
echo "========================================"

# SSH
mkdir -p /var/run/sshd
/usr/sbin/sshd

# Set VNC password
su - ${USER} -c "echo -e '${VNC_PASSWORD}\n${VNC_PASSWORD}' | vncpasswd -u ${USER} -w"

# Start KasmVNC (already configured in Dockerfile)
su - ${USER} -c "kasmvncserver :1 -plainport 6901 -nolisten tcp -geometry 1920x1080 -depth 24" || \
su - ${USER} -c "vncserver :1 -plainport 6901 -geometry 1920x1080 -depth 24"

echo "========================================"
echo "Ready!"
echo "========================================"
echo "SSH:     ssh ${USER}@localhost -p 22"
echo "Web:     http://localhost:6901"
echo "User:    ${USER}"
echo "Password: ${PASSWORD}"
echo "========================================"

tail -f /dev/null
