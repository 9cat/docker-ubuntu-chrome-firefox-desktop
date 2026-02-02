#!/bin/bash
set -e

echo "========================================"
echo "Ubuntu Desktop - Starting"
echo "========================================"

# SSH
mkdir -p /var/run/sshd
/usr/sbin/sshd

# VNC directory
mkdir -p /home/${USER}/.vnc
chown -R ${USER}:${USER} /home/${USER}/.vnc

# VNC password (non-interactive)
echo "${VNC_PASSWORD}" | su - ${USER} -c "vncpasswd -f > /home/${USER}/.vnc/passwd"
chmod 600 /home/${USER}/.vnc/passwd

# VNC xstartup
cat > /home/${USER}/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF
chmod +x /home/${USER}/.vnc/xstartup
chown ${USER}:${USER} /home/${USER}/.vnc/xstartup

# Start TigerVNC
su - ${USER} -c "vncserver ${DISPLAY} -geometry 1920x1080 -depth 24"

# Start noVNC (websockify)
websockify --web=/usr/share/novnc 6901 localhost:5901 &

echo "========================================"
echo "Ready!"
echo "========================================"
echo "SSH:     ssh ${USER}@localhost -p 22"
echo "VNC:     localhost:5901"
echo "Web:     http://localhost:6901/vnc.html"
echo "User:    ${USER}"
echo "Password: ${PASSWORD}"
echo "========================================"

tail -f /dev/null
