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
# 3. KasmVNC
# ============================================
RUN wget -qO - https://github.com/kasmtech/KasmVNC/releases/download/v1.3.1/kasmvnc.asc | \
    gpg --dearmor -o /usr/share/keyrings/kasmvnc-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kasmvnc-archive-keyring.gpg] \
    https://github.com/kasmtech/KasmVNC/releases/download/v1.3.1/deb stable main" > \
    /etc/apt/sources.list.d/kasmvnc.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends kasmvncserver && \
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
# 6. User setup
# ============================================
RUN useradd -m -s /bin/bash -u 1000 ${USER} && \
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
