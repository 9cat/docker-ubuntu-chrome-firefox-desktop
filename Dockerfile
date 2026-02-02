# ============================================
# Ubuntu Desktop Development Environment
# Chrome + Firefox + KasmVNC
# HTTPS enabled with auto-trusted certificates
# Docker-in-Docker support enabled
# ============================================

FROM ubuntu:24.04

LABEL maintainer "temple <temple@iobond.com>"
LABEL description="Minimal Ubuntu Desktop for Development"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    USER=ubuntu \
    PASSWORD=ubuntu \
    VNC_PASSWORD=ubuntu

# ============================================
# 1. Base packages + SSL tools + tmux for debugging
# ============================================
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl wget gnupg sudo locales tzdata \
        openssh-server software-properties-common ssl-cert openssl \
        tmux htop vim libnss3-tools && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 2. Docker CLI + Docker Compose (for Docker-in-Docker)
# ============================================
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 3. XFCE4 desktop
# ============================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        xfce4 xfce4-terminal dbus-x11 \
        xserver-xorg x11-xserver-utils \
        fonts-liberation fonts-dejavu-core && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 3. Firefox ESR from Mozilla PPA (snap doesn't work in Docker)
# ============================================
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && \
    apt-get install -y firefox-esr && \
    ln -sf /usr/bin/firefox-esr /usr/bin/firefox && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 4. KasmVNC - Official installation
# ============================================
RUN wget -q https://github.com/kasmtech/KasmVNC/releases/download/v1.3.2/kasmvncserver_noble_1.3.2_amd64.deb -O /tmp/kasmvncserver.deb && \
    apt-get update && \
    apt-get install -y /tmp/kasmvncserver.deb && \
    rm -f /tmp/kasmvncserver.deb && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 5. Chrome
# ============================================
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends ./google-chrome-stable_current_amd64.deb && \
    rm -f google-chrome-stable_current_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 7. User setup (add to ssl-cert and docker groups)
# ============================================
RUN userdel -r ubuntu 2>/dev/null || true && \
    useradd -m -s /bin/bash -u 1000 ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    usermod -aG sudo ubuntu && \
    usermod -aG ssl-cert ubuntu && \
    usermod -aG docker ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ============================================
# 7. Create Chrome wrapper script (needs --no-sandbox in Docker)
# ============================================
RUN echo '#!/bin/bash' > /usr/local/bin/chrome && \
    echo '# Clear profile lock if exists' >> /usr/local/bin/chrome && \
    echo 'rm -f ~/.config/google-chrome/SingletonLock 2>/dev/null' >> /usr/local/bin/chrome && \
    echo 'rm -f ~/.config/google-chrome/SingletonSocket 2>/dev/null' >> /usr/local/bin/chrome && \
    echo 'rm -f ~/.config/google-chrome/SingletonCookie 2>/dev/null' >> /usr/local/bin/chrome && \
    echo 'exec /usr/bin/google-chrome --no-sandbox --disable-dev-shm-usage "$@"' >> /usr/local/bin/chrome && \
    chmod +x /usr/local/bin/chrome

# ============================================
# 8. Create desktop shortcuts for browsers
# ============================================
RUN mkdir -p /home/ubuntu/Desktop && \
    echo '[Desktop Entry]' > /home/ubuntu/Desktop/chrome.desktop && \
    echo 'Version=1.0' >> /home/ubuntu/Desktop/chrome.desktop && \
    echo 'Type=Application' >> /home/ubuntu/Desktop/chrome.desktop && \
    echo 'Name=Google Chrome' >> /home/ubuntu/Desktop/chrome.desktop && \
    echo 'Exec=/usr/local/bin/chrome %U' >> /home/ubuntu/Desktop/chrome.desktop && \
    echo 'Icon=google-chrome' >> /home/ubuntu/Desktop/chrome.desktop && \
    echo 'Terminal=false' >> /home/ubuntu/Desktop/chrome.desktop && \
    echo 'Categories=Network;WebBrowser;' >> /home/ubuntu/Desktop/chrome.desktop && \
    chmod +x /home/ubuntu/Desktop/chrome.desktop && \
    echo '[Desktop Entry]' > /home/ubuntu/Desktop/firefox.desktop && \
    echo 'Version=1.0' >> /home/ubuntu/Desktop/firefox.desktop && \
    echo 'Type=Application' >> /home/ubuntu/Desktop/firefox.desktop && \
    echo 'Name=Firefox ESR' >> /home/ubuntu/Desktop/firefox.desktop && \
    echo 'Exec=firefox-esr %U' >> /home/ubuntu/Desktop/firefox.desktop && \
    echo 'Icon=firefox-esr' >> /home/ubuntu/Desktop/firefox.desktop && \
    echo 'Terminal=false' >> /home/ubuntu/Desktop/firefox.desktop && \
    echo 'Categories=Network;WebBrowser;' >> /home/ubuntu/Desktop/firefox.desktop && \
    chmod +x /home/ubuntu/Desktop/firefox.desktop && \
    chown -R ubuntu:ubuntu /home/ubuntu/Desktop

# ============================================
# 9. Configure KasmVNC for ubuntu user
# ============================================
RUN mkdir -p /home/ubuntu/.vnc && \
    echo "xfce" > /home/ubuntu/.vnc/de && \
    echo '#!/bin/bash' > /home/ubuntu/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /home/ubuntu/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /home/ubuntu/.vnc/xstartup && \
    echo 'export XDG_SESSION_TYPE=x11' >> /home/ubuntu/.vnc/xstartup && \
    echo 'exec startxfce4' >> /home/ubuntu/.vnc/xstartup && \
    chmod +x /home/ubuntu/.vnc/xstartup && \
    touch /home/ubuntu/.Xauthority && \
    chown -R ubuntu:ubuntu /home/ubuntu

# ============================================
# 10. Configure KasmVNC for root (fallback)
# ============================================
RUN mkdir -p /root/.vnc && \
    echo "xfce" > /root/.vnc/de && \
    echo '#!/bin/bash' > /root/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /root/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /root/.vnc/xstartup && \
    echo 'export XDG_SESSION_TYPE=x11' >> /root/.vnc/xstartup && \
    echo 'exec startxfce4' >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup && \
    touch /root/.Xauthority

# ============================================
# 11. Generate CA and SSL certificates for HTTPS
# ============================================
RUN mkdir -p /etc/kasmvnc/ssl && \
    # Generate CA private key
    openssl genrsa -out /etc/kasmvnc/ssl/ca.key 2048 && \
    # Generate CA certificate
    openssl req -x509 -new -nodes -key /etc/kasmvnc/ssl/ca.key \
        -sha256 -days 3650 -out /etc/kasmvnc/ssl/ca.crt \
        -subj "/C=US/ST=State/L=City/O=KasmVNC CA/CN=KasmVNC Root CA" && \
    # Generate server private key
    openssl genrsa -out /etc/kasmvnc/ssl/kasmvnc.key 2048 && \
    # Create certificate signing request
    openssl req -new -key /etc/kasmvnc/ssl/kasmvnc.key \
        -out /etc/kasmvnc/ssl/kasmvnc.csr \
        -subj "/C=US/ST=State/L=City/O=KasmVNC/CN=localhost" && \
    # Create extension file for SAN
    echo "subjectAltName=DNS:localhost,IP:127.0.0.1" > /etc/kasmvnc/ssl/ext.cnf && \
    # Sign server certificate with CA
    openssl x509 -req -in /etc/kasmvnc/ssl/kasmvnc.csr \
        -CA /etc/kasmvnc/ssl/ca.crt -CAkey /etc/kasmvnc/ssl/ca.key \
        -CAcreateserial -out /etc/kasmvnc/ssl/kasmvnc.crt \
        -days 365 -sha256 -extfile /etc/kasmvnc/ssl/ext.cnf && \
    # Set permissions
    chmod 644 /etc/kasmvnc/ssl/*.key /etc/kasmvnc/ssl/*.crt && \
    # Install CA to system trust store
    cp /etc/kasmvnc/ssl/ca.crt /usr/local/share/ca-certificates/kasmvnc-ca.crt && \
    update-ca-certificates

# ============================================
# 12. SSH config - allow password auth
# ============================================
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ============================================
# 13. Entrypoint
# ============================================
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 6901 51200-51239

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s \
    CMD pgrep -f kasmvncserver || exit 1

USER ubuntu
WORKDIR /home/ubuntu

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
