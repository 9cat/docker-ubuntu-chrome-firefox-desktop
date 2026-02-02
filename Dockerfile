# ============================================
# Ubuntu Desktop Development Environment
# Chrome + Firefox + KasmVNC with HTTPS
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
# 1. Base packages + SSL tools
# ============================================
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl wget gnupg sudo locales tzdata \
        openssh-server software-properties-common ssl-cert openssl && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 2. xfce4 desktop + Firefox
# ============================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        xfce4 xfce4-terminal dbus-x11 \
        xserver-xorg x11-xserver-utils \
        fonts-liberation fonts-dejavu-core \
        firefox && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 3. KasmVNC - Official installation
# ============================================
RUN wget -q https://github.com/kasmtech/KasmVNC/releases/download/v1.3.2/kasmvncserver_noble_1.3.2_amd64.deb -O /tmp/kasmvncserver.deb && \
    apt-get update && \
    apt-get install -y /tmp/kasmvncserver.deb && \
    rm -f /tmp/kasmvncserver.deb && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 4. Chrome
# ============================================
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends ./google-chrome-stable_current_amd64.deb && \
    rm -f google-chrome-stable_current_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 5. User setup (add to ssl-cert group for HTTPS)
# ============================================
RUN userdel -r ubuntu 2>/dev/null || true && \
    useradd -m -s /bin/bash -u 1000 ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    usermod -aG sudo ubuntu && \
    usermod -aG ssl-cert ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ============================================
# 6. Create Chrome wrapper script (needs --no-sandbox in Docker)
# ============================================
RUN echo '#!/bin/bash' > /usr/local/bin/chrome && \
    echo 'exec /usr/bin/google-chrome --no-sandbox --disable-dev-shm-usage "$@"' >> /usr/local/bin/chrome && \
    chmod +x /usr/local/bin/chrome

# ============================================
# 7. Create desktop shortcuts for browsers
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
    echo 'Name=Firefox' >> /home/ubuntu/Desktop/firefox.desktop && \
    echo 'Exec=firefox %U' >> /home/ubuntu/Desktop/firefox.desktop && \
    echo 'Icon=firefox' >> /home/ubuntu/Desktop/firefox.desktop && \
    echo 'Terminal=false' >> /home/ubuntu/Desktop/firefox.desktop && \
    echo 'Categories=Network;WebBrowser;' >> /home/ubuntu/Desktop/firefox.desktop && \
    chmod +x /home/ubuntu/Desktop/firefox.desktop && \
    chown -R ubuntu:ubuntu /home/ubuntu/Desktop

# ============================================
# 8. Configure KasmVNC for ubuntu user
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
# 9. Configure KasmVNC for root (fallback)
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
# 10. Generate self-signed SSL certificate for HTTPS
# ============================================
RUN mkdir -p /etc/kasmvnc/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/kasmvnc/ssl/kasmvnc.key \
        -out /etc/kasmvnc/ssl/kasmvnc.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" && \
    chmod 644 /etc/kasmvnc/ssl/kasmvnc.key && \
    chmod 644 /etc/kasmvnc/ssl/kasmvnc.crt

# ============================================
# 11. SSH config - allow password auth
# ============================================
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ============================================
# 12. Entrypoint
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
