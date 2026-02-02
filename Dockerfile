# ============================================
# Ubuntu Desktop Development Environment
# Chrome + Firefox + KasmVNC
# ============================================

FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble

LABEL maintainer "temple <temple@iobond.com>"
LABEL description="Minimal Ubuntu Desktop for Development"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    USER=ubuntu \
    PASSWORD=ubuntu

# ============================================
# Install xfce4 desktop
# ============================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        xfce4 xfce4-terminal dbus-x11 firefox && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# Install Chrome
# ============================================
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends ./google-chrome-stable_current_amd64.deb && \
    rm -f google-chrome-stable_current_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# Create startwm.sh to launch xfce4
# ============================================
RUN echo '#!/bin/bash' > /defaults/startwm.sh && \
    echo 'unset SESSION_MANAGER' >> /defaults/startwm.sh && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /defaults/startwm.sh && \
    echo 'exec startxfce4' >> /defaults/startwm.sh && \
    chmod +x /defaults/startwm.sh

# ============================================
# Create ubuntu user
# ============================================
RUN useradd -m -s /bin/bash -u 1000 ${USER} && \
    echo "${USER}:${PASSWORD}" | chpasswd && \
    usermod -aG sudo ${USER}

EXPOSE 3000 51200-51239
