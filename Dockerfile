# ============================================
# Ubuntu Desktop Development Environment
# Chrome + Firefox + KasmVNC
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
        openssh-server software-properties-common && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 2. xfce4 desktop
# ============================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        xfce4 xfce4-terminal dbus-x11 \
        xserver-xorg x11-xserver-utils \
        fonts-liberation fonts-dejavu-core && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 3. KasmVNC - Ubuntu 24.04 (noble)
# ============================================
RUN wget -q https://github.com/kasmtech/KasmVNC/releases/download/v1.3.2/kasmvncserver_noble_1.3.2_amd64.deb -O /tmp/kasmvnc.deb && \
    apt-get update && \
    apt-get install -y /tmp/kasmvnc.deb && \
    rm -f /tmp/kasmvnc.deb && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 4. Firefox
# ============================================
RUN apt-get update && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    apt-get install -y --no-install-recommends firefox && \
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
# 6. User setup (remove if exists, then create)
# ============================================
RUN userdel -r ${USER} 2>/dev/null || true && \
    useradd -m -s /bin/bash -u 1000 ${USER} && \
    echo "${USER}:${PASSWORD}" | chpasswd && \
    usermod -aG sudo ${USER}

# ============================================
# 7. Entrypoint
# ============================================
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 6901
HEALTHCHECK CMD pgrep xfce4-session || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
