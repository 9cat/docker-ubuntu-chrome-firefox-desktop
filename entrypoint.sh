#!/bin/bash
set -e

echo "========================================"
echo "Ubuntu Desktop - Starting"
echo "========================================"

# SSH - create required directory
mkdir -p /var/run/sshd
/usr/sbin/sshd

# KasmVNC
su - ${USER} -c "vncserver -configure :1"
su - ${USER} -c "echo '${VNC_PASSWORD}' | vncpasswd -file > ~/.vnc/passwd"
chmod 600 /home/${USER}/.vnc/passwd
su - ${USER} -c "vncserver :1 -localhost no -cert none -plainport 6901"

echo "========================================"
echo "Ready!"
echo "========================================"
echo "SSH:     ssh ${USER}@localhost -p 22"
echo "Web:     https://localhost:6901"
echo "User:    ${USER}"
echo "Password: ${PASSWORD}"
echo "========================================"

tail -f /dev/null
