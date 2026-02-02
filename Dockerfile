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
RUN userdel -r ${USER} 2>/dev/null || true && \
    useradd -m -s /bin/bash -u 1000 ${USER} && \
    echo "${USER}:${PASSWORD}" | chpasswd && \
    usermod -aG sudo ${USER} && \
    usermod -aG ssl-cert ${USER}

# ============================================
# 6. Create /defaults/startwm.sh to bypass desktop selection
# ============================================
RUN mkdir -p /defaults && \
    echo '#!/bin/bash' > /defaults/startwm.sh && \
    echo '' >> /defaults/startwm.sh && \
    echo '# KasmVNC window manager startup script' >> /defaults/startwm.sh && \
    echo 'unset SESSION_MANAGER' >> /defaults/startwm.sh && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /defaults/startwm.sh && \
    echo 'exec startxfce4' >> /defaults/startwm.sh && \
    chmod +x /defaults/startwm.sh

# ============================================
# 7. Pre-configure VNC directory
# ============================================
RUN mkdir -p /home/${USER}/.vnc && \
    chown -R ${USER}:${USER} /home/${USER}/.vnc && \
    echo '#!/bin/bash' > /home/${USER}/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /home/${USER}/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /home/${USER}/.vnc/xstartup && \
    echo 'exec startxfce4' >> /home/${USER}/.vnc/xstartup && \
    chmod +x /home/${USER}/.vnc/xstartup && \
    chown ${USER}:${USER} /home/${USER}/.vnc/xstartup

# ============================================
# 8. Generate self-signed SSL certificate for HTTPS
# ============================================
RUN mkdir -p /etc/kasmvnc/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/kasmvnc/ssl/kasmvnc.key \
        -out /etc/kasmvnc/ssl/kasmvnc.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" && \
    chmod 600 /etc/kasmvnc/ssl/kasmvnc.key && \
    chmod 644 /etc/kasmvnc/ssl/kasmvnc.crt && \
    chown -R ${USER}:ssl-cert /etc/kasmvnc/ssl

# ============================================
# 9. Entrypoint
# ============================================
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 6901 51200-51239

HEALTHCHECK CMD pgrep xfce4-session || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
