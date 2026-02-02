#!/bin/bash
set -e

echo "========================================"
echo "Ubuntu Desktop - Starting with HTTPS"
echo "========================================"

# SSH
mkdir -p /var/run/sshd
/usr/sbin/sshd

# Create .vnc directory and xstartup for user
USER_HOME="/home/${USER}"
mkdir -p ${USER_HOME}/.vnc
chown -R ${USER}:${USER} ${USER_HOME}/.vnc

# Create xstartup to auto-select XFCE (avoids interactive prompt)
cat > ${USER_HOME}/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_SESSION_TYPE=x11
exec startxfce4
EOF
chmod +x ${USER_HOME}/.vnc/xstartup
chown ${USER}:${USER} ${USER_HOME}/.vnc/xstartup

# Create Xauthority file
touch ${USER_HOME}/.Xauthority
chown ${USER}:${USER} ${USER_HOME}/.Xauthority

# Set VNC password
su - ${USER} -c "echo -e '${VNC_PASSWORD}\n${VNC_PASSWORD}' | vncpasswd -u ${USER} -w"

# Start KasmVNC with HTTPS support
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
