#!/bin/bash
set -e

echo "========================================"
echo "Ubuntu Desktop - Starting"
echo "========================================"

# Start SSH (needs sudo since we run as ubuntu)
sudo mkdir -p /var/run/sshd
sudo /usr/sbin/sshd

# Create VNC config directory (volume mount may overwrite it)
mkdir -p ~/.vnc

# Create 'de' file to auto-select XFCE (MUST be done at runtime due to volume mount)
echo "xfce" > ~/.vnc/de

# Create xstartup file
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_SESSION_TYPE=x11
exec startxfce4
EOF
chmod +x ~/.vnc/xstartup

# Create Xauthority if missing
touch ~/.Xauthority

# Set VNC password for current user
echo -e "${VNC_PASSWORD:-ubuntu}\n${VNC_PASSWORD:-ubuntu}" | vncpasswd -u $(whoami) -w 2>/dev/null || true

# Debug: verify de file exists
echo "VNC config files:"
ls -la ~/.vnc/
cat ~/.vnc/de

# Start KasmVNC with -select-de to bypass interactive prompt
echo "Starting KasmVNC..."
kasmvncserver :1 \
    -websocketPort 6901 \
    -cert /etc/kasmvnc/ssl/kasmvnc.crt \
    -key /etc/kasmvnc/ssl/kasmvnc.key \
    -geometry 1920x1080 \
    -depth 24 \
    -select-de xfce 2>&1 || echo "KasmVNC startup completed"

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
