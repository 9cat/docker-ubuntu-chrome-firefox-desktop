#!/bin/bash
set -e

echo "========================================"
echo "Ubuntu Desktop - Starting"
echo "========================================"

# Reset ubuntu password (in case volume mount changed it)
echo "ubuntu:${PASSWORD:-ubuntu}" | sudo chpasswd

# Setup SSH key auth for remote debugging
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat > ~/.ssh/authorized_keys << 'SSHKEY'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEXRZki8xRY4FLdp16PrHWsqr8nbVlYJrqy7qF2pFWO claude@daydream
SSHKEY
chmod 600 ~/.ssh/authorized_keys

# Start SSH (needs sudo since we run as ubuntu)
sudo mkdir -p /var/run/sshd
sudo /usr/sbin/sshd

# ============================================
# Install CA certificate for browsers
# ============================================
echo "Installing CA certificate for browsers..."

# Install CA cert for Chrome (uses shared NSS database)
mkdir -p ~/.pki/nssdb
# Initialize NSS database if it doesn't exist
if [ ! -f ~/.pki/nssdb/cert9.db ]; then
    certutil -d sql:$HOME/.pki/nssdb -N --empty-password
fi
# Remove old CA if exists and add new one
certutil -d sql:$HOME/.pki/nssdb -D -n "KasmVNC CA" 2>/dev/null || true
certutil -d sql:$HOME/.pki/nssdb -A -n "KasmVNC CA" -t "CT,C,C" -i /etc/kasmvnc/ssl/ca.crt

# Install CA cert for Firefox (uses per-profile NSS database)
# Firefox ESR creates profile on first run, so we pre-create one
FIREFOX_PROFILE_DIR="$HOME/.mozilla/firefox"
mkdir -p "$FIREFOX_PROFILE_DIR"

# Create profiles.ini if it doesn't exist
if [ ! -f "$FIREFOX_PROFILE_DIR/profiles.ini" ]; then
    mkdir -p "$FIREFOX_PROFILE_DIR/default"
    cat > "$FIREFOX_PROFILE_DIR/profiles.ini" << 'PROFILES'
[General]
StartWithLastProfile=1

[Profile0]
Name=default
IsRelative=1
Path=default
Default=1
PROFILES
fi

# Initialize Firefox NSS database and add CA cert
FIREFOX_DEFAULT="$FIREFOX_PROFILE_DIR/default"
mkdir -p "$FIREFOX_DEFAULT"
if [ ! -f "$FIREFOX_DEFAULT/cert9.db" ]; then
    certutil -d sql:$FIREFOX_DEFAULT -N --empty-password
fi
certutil -d sql:$FIREFOX_DEFAULT -D -n "KasmVNC CA" 2>/dev/null || true
certutil -d sql:$FIREFOX_DEFAULT -A -n "KasmVNC CA" -t "CT,C,C" -i /etc/kasmvnc/ssl/ca.crt

echo "CA certificate installed for Chrome and Firefox"

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

# Create Desktop directory and browser shortcuts (volume mount overwrites these)
mkdir -p ~/Desktop
cat > ~/Desktop/chrome.desktop << 'CHROME'
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Chrome
Exec=/usr/local/bin/chrome %U
Icon=google-chrome
Terminal=false
Categories=Network;WebBrowser;
CHROME
chmod +x ~/Desktop/chrome.desktop

cat > ~/Desktop/firefox.desktop << 'FIREFOX'
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox ESR
Exec=firefox-esr %U
Icon=firefox-esr
Terminal=false
Categories=Network;WebBrowser;
FIREFOX
chmod +x ~/Desktop/firefox.desktop

# Set VNC password for current user
echo -e "${VNC_PASSWORD:-ubuntu}\n${VNC_PASSWORD:-ubuntu}" | vncpasswd -u $(whoami) -w 2>/dev/null || true

# Debug: verify de file exists
echo "VNC config files:"
ls -la ~/.vnc/
cat ~/.vnc/de

# Set environment variable to skip DE selection
export SELECT_DE=1
export KASM_VNC_DE=xfce

# Start KasmVNC with HTTPS
echo "Starting KasmVNC with HTTPS..."
echo "1" | kasmvncserver :1 \
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
echo ""
echo "Note: CA certificate is pre-installed in Chrome and Firefox"
echo "========================================"

# Keep container running
tail -f /dev/null
