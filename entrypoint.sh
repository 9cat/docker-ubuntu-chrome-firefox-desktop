#!/bin/bash
set -e

echo "========================================"
echo "Ubuntu Desktop - Starting"
echo "========================================"

# Start SSH (needs sudo since we run as ubuntu)
sudo mkdir -p /var/run/sshd
sudo /usr/sbin/sshd

# Set VNC password for current user
echo -e "${VNC_PASSWORD:-ubuntu}\n${VNC_PASSWORD:-ubuntu}" | vncpasswd -u $(whoami) -w 2>/dev/null || true

# Start KasmVNC
echo "Starting KasmVNC..."
kasmvncserver :1 \
    -websocketPort 6901 \
    -cert /etc/kasmvnc/ssl/kasmvnc.crt \
    -key /etc/kasmvnc/ssl/kasmvnc.key \
    -geometry 1920x1080 \
    -depth 24 2>&1 || echo "KasmVNC startup completed"

sleep 2

echo "========================================"
echo "Ready!"
echo "========================================"
echo "SSH:     ssh ubuntu@<host> -p 10022"
echo "Web:     https://<host>:16901"
echo "User:    ubuntu"
echo "Password: ${PASSWORD:-ubuntu}"
echo "========================================"

# Keep container running
tail -f /dev/null
