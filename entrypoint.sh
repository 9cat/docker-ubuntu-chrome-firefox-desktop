#!/bin/bash
set -e

echo "========================================"
echo "Ubuntu Desktop - Starting with HTTPS"
echo "========================================"

# SSH
mkdir -p /var/run/sshd
/usr/sbin/sshd

# Set VNC password
su - ${USER} -c "echo -e '${VNC_PASSWORD}\n${VNC_PASSWORD}' | vncpasswd -u ${USER} -w"

# Start KasmVNC with HTTPS support
# -cert and -key options enable HTTPS
su - ${USER} -c "kasmvncserver :1 \
    -plainport 5901 \
    -webport 6901 \
    -cert /etc/kasmvnc/ssl/kasmvnc.crt \
    -key /etc/kasmvnc/ssl/kasmvnc.key \
    -geometry 1920x1080 \
    -depth 24 \
    -nolisten tcp" || \
su - ${USER} -c "vncserver :1 \
    -plainport 5901 \
    -geometry 1920x1080 \
    -depth 24"

echo "========================================"
echo "Ready!"
echo "========================================"
echo "SSH:     ssh ${USER}@localhost -p 22"
echo "Web:     https://localhost:6901 (HTTPS)"
echo "User:    ${USER}"
echo "Password: ${PASSWORD}"
echo "========================================"

tail -f /dev/null
