# ============================================
# Ubuntu Desktop Development Environment
# Chrome + Firefox + KasmVNC
# Following official KasmVNC installation guide
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
# 1. Base packages
# ============================================
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl wget gnupg sudo locales tzdata \
        openssh-server software-properties-common ssl-cert && \
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
#    Following: https://github.com/kasmtech/KasmVNC
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
# 5. User setup (add to ssl-cert group for KasmVNC)
# ============================================
RUN userdel -r ${USER} 2>/dev/null || true && \
    useradd -m -s /bin/bash -u 1000 ${USER} && \
    echo "${USER}:${PASSWORD}" | chpasswd && \
    usermod -aG sudo ${USER} && \
    usermod -aG ssl-cert ${USER}

# ============================================
# 6. Pre-configure KasmVNC (avoid interactive setup)
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
# 7. Entrypoint
# ============================================
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# KasmVNC web interface port + display port
EXPOSE 22 6901 51200-51239

HEALTHCHECK CMD pgrep xfce4-session || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
