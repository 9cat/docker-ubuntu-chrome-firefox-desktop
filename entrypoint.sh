#!/bin/bash
set -e

USER=${USER:-ubuntu}
USER_HOME="/home/${USER}"

echo "========================================"
echo "Ubuntu Desktop - Starting with HTTPS"
echo "========================================"

# SSH
mkdir -p /var/run/sshd
/usr/sbin/sshd

# Create .vnc directory for user
mkdir -p ${USER_HOME}/.vnc

# Create 'de' file to auto-select XFCE (KasmVNC reads this to skip interactive prompt)
echo "xfce" > ${USER_HOME}/.vnc/de

# Create xstartup file
cat > ${USER_HOME}/.vnc/xstartup << 'XSTARTUP'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_SESSION_TYPE=x11
exec startxfce4
XSTARTUP
chmod +x ${USER_HOME}/.vnc/xstartup

# Create Xauthority file
touch ${USER_HOME}/.Xauthority

# Fix ownership
chown -R ${USER}:${USER} ${USER_HOME}/.vnc
chown ${USER}:${USER} ${USER_HOME}/.Xauthority

# Set VNC password
su - ${USER} -c "echo -e '${VNC_PASSWORD}\n${VNC_PASSWORD}' | vncpasswd -u ${USER} -w" || true

# Start KasmVNC with HTTPS support
su - ${USER} -c "kasmvncserver :1 \
    -websocketPort 6901 \
    -cert /etc/kasmvnc/ssl/kasmvnc.crt \
    -key /etc/kasmvnc/ssl/kasmvnc.key \
    -geometry 1920x1080 \
    -depth 24" || \
su - ${USER} -c "vncserver :1 \
    -geometry 1920x1080 \
    -depth 24" || true

echo "========================================"
echo "Ready!"
echo "========================================"
echo "SSH:     ssh ${USER}@localhost -p 22"
echo "Web:     https://localhost:6901 (HTTPS)"
echo "User:    ${USER}"
echo "Password: ${PASSWORD}"
echo "========================================"

tail -f /dev/null
