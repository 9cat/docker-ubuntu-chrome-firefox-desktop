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

# Pre-create KasmVNC config to skip desktop selection
cat > /home/${USER}/.vnc/kasmvnc.yaml << 'EOF'
# KasmVNC configuration
environment:
  scale: 1
EOF
chown ${USER}:${USER} /home/${USER}/.vnc/kasmvnc.yaml

# Create xstartup file
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

# Start KasmVNC as ubuntu user (use vncserver directly, no display config)
su - ${USER} -c "kasmvncserver :1 -plainport 6901 -nolisten tcp -geometry 1920x1080 -depth 24" || \
su - ${USER} -c "vncserver :1 -plainport 6901 -geometry 1920x1080 -depth 24"

echo "========================================"
echo "Ready!"
echo "========================================"
echo "SSH:     ssh ${USER}@localhost -p 22"
echo "Web:     https://localhost:6901"
echo "User:    ${USER}"
echo "Password: ${PASSWORD}"
echo "========================================"

tail -f /dev/null
