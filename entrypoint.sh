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

# Create KasmVNC xstartup to auto-select XFCE
cat > /home/${USER}/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF
chmod +x /home/${USER}/.vnc/xstartup
chown ${USER}:${USER} /home/${USER}/.vnc/xstartup

# Set KasmVNC password
su - ${USER} -c "echo -e '${VNC_PASSWORD}\n${VNC_PASSWORD}' | vncpasswd -u ${USER} -w"

# Start KasmVNC as ubuntu user
su - ${USER} -c "vncserver :1 -localhost no -cert none -plainport 6901 -depth 24 -geometry 1920x1080"

echo "========================================"
echo "Ready!"
echo "========================================"
echo "SSH:     ssh ${USER}@localhost -p 22"
echo "Web:     https://localhost:6901"
echo "User:    ${USER}"
echo "Password: ${PASSWORD}"
echo "========================================"

tail -f /dev/null
