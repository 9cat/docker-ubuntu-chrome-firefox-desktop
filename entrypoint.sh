#!/bin/bash
# Don't use set -e - we want the script to continue even if some commands fail

echo "========================================"
echo "Ubuntu Desktop - Starting"
echo "========================================"

# ============================================
# Fix home directory ownership (bind mount may be root-owned)
# ============================================
sudo chown temple:temple /home/temple

# Copy skeleton files if home is empty (bind mount)
for f in .bashrc .profile; do
    [ ! -f ~/$f ] && [ -f /etc/skel/$f ] && cp /etc/skel/$f ~/
done

# Ensure /usr/local/bin is in PATH for Claude Code
# Remove old PATH settings that might be wrong
sed -i '/PATH.*\.local\/bin/d' ~/.bashrc 2>/dev/null
sed -i '/PATH.*\.local\/bin/d' ~/.bashrc 2>/dev/null
# Add correct PATH at the end of .bashrc
grep -q "/usr/local/bin" ~/.bashrc 2>/dev/null || echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
export PATH="/usr/local/bin:$PATH"

# ============================================
# Setup fcitx5 input method for Chinese
# ============================================
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx

# Add to .bashrc for persistence
grep -q "GTK_IM_MODULE" ~/.bashrc 2>/dev/null || cat >> ~/.bashrc << 'IMEOF'
# Chinese input method (fcitx5)
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx

# Chinese locale
export LANG=zh_CN.UTF-8

# Auto-attach to tmux dev session on SSH login
if [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX" ]; then
    tmux attach -t dev 2>/dev/null || tmux new-session -s dev
fi
IMEOF

# Reset temple password (in case volume mount changed it)
echo "temple:${PASSWORD:-temple}" | sudo chpasswd

# Setup SSH authorized keys (always reset to ensure correct keys)
mkdir -p ~/.ssh
chmod 700 ~/.ssh
if [ -n "$SSH_PUBLIC_KEY" ]; then
    # Use environment variable if provided
    echo "$SSH_PUBLIC_KEY" > ~/.ssh/authorized_keys
    echo "SSH key configured from environment variable"
else
    # Always set default keys (ensures correct keys even with persistent volume)
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfsqGnzHpkyEwfpA77IRpM7L8Olv0GS5rKn+vSSgt2lavCnW6GIZ4sgJYRVcNAZj+JQeAPFjCLbKBqBQtG49PqMKMTGPkQY2ey6mbjO8VDEqBOClVyUroWweszh2OzYeKNIqAkhsh0NisQZytKpEPXDygkWG6inPaME1QeIe+/lcsWfsOhC4J4WcG1QiH46sq78hf7vwM5Em4iHoi9Eofbx2kKSlv7G8rpJj0CkPuYUSw7SLkFwYxR8sTmy+BsBJc6MoZ0IsfTLD3Qd4CSmCc2jEhAEsOuIoQSKKsXfUDguEIF1kVP5OUC8K40ZV+ixNjkMWQfMFPkEnbN5lL9KYof default-rsa-key-1" > ~/.ssh/authorized_keys
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDnLbpUAfFJSCJNtozZJP4iKdXxJ/Q/+bDoVFY5erzdUQfPGoxcOHRdEgmN6DbJHNE8uEOFU61qV9M0mB++kTnUb+FSPnFyf0ga6rG/80pknWDXRfI7BBTKCCbiRDt6poaCb5u9+ACNQVWlE5QZqqfgWgE6J7oaLN/yXPPFV9GYyFuVbRuSOAE+b3K4zTIQE2gYFCr2m7dL0LDjqF+VpOyOHSaX7mWDes61hfrBfNZc0s9UcMQsBMJXLPr/cqOt63rEJeHZAxv5Nz3MrtJyyBaCjZdPG8N6GTpEv8aVuaJ7warlfKopJk7gleTCVlCbBCXqj92x8HxFux0jcQhEMvFv default-rsa-key-2" >> ~/.ssh/authorized_keys
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEXRZki8xRY4FLdp16PrHWsqr8nbVlYJrqy7qF2pFWO default-ed25519-key" >> ~/.ssh/authorized_keys
    echo "Using default SSH keys"
fi
chmod 600 ~/.ssh/authorized_keys

# Start SSH (needs sudo since we run as temple)
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
echo -e "${VNC_PASSWORD:-temple}\n${VNC_PASSWORD:-temple}" | vncpasswd -u $(whoami) -w 2>/dev/null || true

# Debug: verify de file exists
echo "VNC config files:"
ls -la ~/.vnc/
cat ~/.vnc/de

# Set environment variable to skip DE selection
export SELECT_DE=1
export KASM_VNC_DE=xfce

# Start KasmVNC with HTTPS
echo "Starting KasmVNC with HTTPS..."
# Pipe "1" to select XFCE and "y" to confirm overwrite of xstartup
echo -e "1\ny" | kasmvncserver :1 \
    -websocketPort 6901 \
    -cert /etc/kasmvnc/ssl/kasmvnc.crt \
    -key /etc/kasmvnc/ssl/kasmvnc.key \
    -geometry 1920x1080 \
    -depth 24 2>&1 || echo "KasmVNC startup completed"

sleep 2

# ============================================
# Start Docker daemon for true Docker-in-Docker
# ============================================
echo "Starting Docker daemon (DinD)..."

# Clean up any stale state
echo "[Docker] Cleaning up any stale state..."
sudo rm -f /var/run/docker.sock /var/run/docker.pid 2>/dev/null || true
sudo killall dockerd containerd 2>/dev/null || true
sleep 1

# Create log file first to ensure it exists
sudo touch /var/log/dockerd.log
sudo chmod 644 /var/log/dockerd.log

# Start dockerd using nohup to ensure it survives
# Note: Must use 'sudo sh -c' so redirection happens as root, not current user
echo "[Docker] Starting dockerd with overlay2 storage driver..."
sudo sh -c 'nohup dockerd --storage-driver=overlay2 >> /var/log/dockerd.log 2>&1 &'
echo "[Docker] dockerd started in background"

# Wait for Docker to be ready (up to 30 seconds)
echo "[Docker] Waiting for Docker daemon to be ready..."
for i in $(seq 1 30); do
    if docker info > /dev/null 2>&1; then
        echo "[Docker] Docker daemon is ready! (took ${i}s)"
        break
    fi
    sleep 1
    if [ $i -eq 30 ]; then
        echo "[Docker] WARNING: Docker daemon did not become ready in 30s"
        echo "[Docker] Log contents:"
        sudo cat /var/log/dockerd.log | tail -20
    fi
done

# ============================================
# Start tmux session for Claude Code development
# ============================================
echo "Starting tmux session 'dev'..."

# Claude Code is in /usr/local/bin/claude, accessible globally
tmux new-session -d -s dev -n claude
tmux send-keys -t dev:claude "cd ~" C-m
tmux send-keys -t dev:claude "claude --dangerously-skip-permissions" C-m

# Create a second window for general shell
tmux new-window -t dev -n shell
tmux send-keys -t dev:shell "cd ~" C-m

# Switch back to first window
tmux select-window -t dev:claude

echo "========================================"
echo "Ready!"
echo "========================================"
echo "SSH:     ssh temple@<host> -p 10022"
echo "Web:     https://<host>:16901"
echo "User:    temple"
echo "Password: ${PASSWORD:-temple}"
echo "========================================"
echo ""
echo "Claude Code: Attach to tmux session"
echo "  tmux attach -t dev"
echo ""
echo "tmux windows:"
echo "  0:claude  - For Claude Code development"
echo "  1:shell   - General shell"
echo ""
echo "tmux shortcuts:"
echo "  Ctrl+b d  - Detach from session"
echo "  Ctrl+b n  - Next window"
echo "  Ctrl+b p  - Previous window"
echo "========================================"

# Keep container running
tail -f /dev/null
