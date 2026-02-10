# ============================================
# Ubuntu Desktop Development Environment
# Chrome + Firefox + KasmVNC + Claude Code
# HTTPS enabled with auto-trusted certificates
# Docker-in-Docker support enabled
# CUDA/OpenGL hardware acceleration support
# ============================================
# Build with CUDA:
#   docker build --build-arg BASE_IMAGE=nvidia/cuda:12.6.2-devel-ubuntu24.04 -t temple-desktop:cuda .
# Build without CUDA:
#   docker build -t temple-desktop:latest .
# ============================================

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

LABEL maintainer "temple <temple@iobond.com>"
LABEL description="Minimal Ubuntu Desktop for Development with CUDA/OpenGL support"

# ============================================
# NVIDIA Container Runtime Configuration
# These enable GPU passthrough when using nvidia-docker
# ============================================
ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    USER=temple \
    PASSWORD=temple \
    VNC_PASSWORD=temple \
    SSH_PUBLIC_KEY="" \
    VGL_DISPLAY=egl

# ============================================
# 1. Base packages + SSL tools + tmux + git
# ============================================
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl wget gnupg sudo locales tzdata \
        openssh-server software-properties-common ssl-cert openssl \
        tmux htop vim libnss3-tools git ripgrep lsb-release && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# ============================================
# 1c. OpenGL libraries and NVIDIA EGL configuration
# Enables hardware-accelerated rendering via NVIDIA GPU
# ============================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libxau6 libxdmcp6 libxcb1 libxext6 libx11-6 \
        libglvnd0 libgl1 libglx0 libegl1 libgles2 \
        libglvnd-dev libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev \
        mesa-utils && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/share/glvnd/egl_vendor.d/ && \
    echo '{"file_format_version":"1.0.0","ICD":{"library_path":"libEGL_nvidia.so.0"}}' \
        > /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# ============================================
# 1d. Vulkan support for NVIDIA GPU
# ============================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends vulkan-tools libvulkan1 && \
    rm -rf /var/lib/apt/lists/* && \
    VULKAN_API_VERSION=$(dpkg -s libvulkan1 | grep -oP 'Version: [0-9|\.]+' | grep -oP '[0-9]+(\.[0-9]+)(\.[0-9]+)') && \
    mkdir -p /etc/vulkan/icd.d/ && \
    echo "{\"file_format_version\":\"1.0.0\",\"ICD\":{\"library_path\":\"libGLX_nvidia.so.0\",\"api_version\":\"${VULKAN_API_VERSION}\"}}" \
        > /etc/vulkan/icd.d/nvidia_icd.json

# ============================================
# 1e. VirtualGL for hardware-accelerated 3D rendering
# Usage: vglrun <application> (e.g., vglrun glxgears)
# ============================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libxtst6 libxv1 libturbojpeg libglu1-mesa && \
    VIRTUALGL_VERSION=3.1.1 && \
    curl -fsSL "https://github.com/VirtualGL/virtualgl/releases/download/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb" -o /tmp/virtualgl.deb && \
    dpkg -i /tmp/virtualgl.deb && \
    rm /tmp/virtualgl.deb && \
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
# 3b. Chinese fonts and input methods (Pinyin + Wubi)
# ============================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fonts-wqy-zenhei fonts-wqy-microhei fonts-noto-cjk \
        fcitx5 fcitx5-chinese-addons fcitx5-frontend-gtk3 \
        fcitx5-config-qt im-config && \
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
    userdel -r temple 2>/dev/null || true && \
    useradd -m -s /bin/bash -u 1000 temple && \
    echo "temple:temple" | chpasswd && \
    usermod -aG sudo temple && \
    usermod -aG ssl-cert temple && \
    usermod -aG docker temple && \
    echo "temple ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

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
# 7b. Set Chrome as default browser
# ============================================
RUN mkdir -p /home/temple/.config/xfce4 && \
    echo '[Configuration]' > /home/temple/.config/xfce4/helpers.rc && \
    echo 'WebBrowser=custom-WebBrowser' >> /home/temple/.config/xfce4/helpers.rc && \
    mkdir -p /home/temple/.local/share/xfce4/helpers && \
    echo '[Desktop Entry]' > /home/temple/.local/share/xfce4/helpers/custom-WebBrowser.desktop && \
    echo 'NoDisplay=true' >> /home/temple/.local/share/xfce4/helpers/custom-WebBrowser.desktop && \
    echo 'Version=1.0' >> /home/temple/.local/share/xfce4/helpers/custom-WebBrowser.desktop && \
    echo 'Encoding=UTF-8' >> /home/temple/.local/share/xfce4/helpers/custom-WebBrowser.desktop && \
    echo 'Type=X-XFCE-Helper' >> /home/temple/.local/share/xfce4/helpers/custom-WebBrowser.desktop && \
    echo 'X-XFCE-Category=WebBrowser' >> /home/temple/.local/share/xfce4/helpers/custom-WebBrowser.desktop && \
    echo 'X-XFCE-CommandsWithParameter=/usr/local/bin/chrome "%s"' >> /home/temple/.local/share/xfce4/helpers/custom-WebBrowser.desktop && \
    echo 'X-XFCE-Commands=/usr/local/bin/chrome' >> /home/temple/.local/share/xfce4/helpers/custom-WebBrowser.desktop && \
    echo 'Name=Google Chrome' >> /home/temple/.local/share/xfce4/helpers/custom-WebBrowser.desktop && \
    echo 'Icon=google-chrome' >> /home/temple/.local/share/xfce4/helpers/custom-WebBrowser.desktop && \
    chown -R temple:temple /home/temple/.config/xfce4 /home/temple/.local/share/xfce4

# Set xdg-open default browser
RUN mkdir -p /home/temple/.config && \
    echo '[Default Applications]' > /home/temple/.config/mimeapps.list && \
    echo 'text/html=chrome.desktop' >> /home/temple/.config/mimeapps.list && \
    echo 'x-scheme-handler/http=chrome.desktop' >> /home/temple/.config/mimeapps.list && \
    echo 'x-scheme-handler/https=chrome.desktop' >> /home/temple/.config/mimeapps.list && \
    echo 'x-scheme-handler/about=chrome.desktop' >> /home/temple/.config/mimeapps.list && \
    echo 'x-scheme-handler/unknown=chrome.desktop' >> /home/temple/.config/mimeapps.list && \
    chown temple:temple /home/temple/.config/mimeapps.list

# Create chrome.desktop for xdg-open
RUN mkdir -p /home/temple/.local/share/applications && \
    echo '[Desktop Entry]' > /home/temple/.local/share/applications/chrome.desktop && \
    echo 'Version=1.0' >> /home/temple/.local/share/applications/chrome.desktop && \
    echo 'Type=Application' >> /home/temple/.local/share/applications/chrome.desktop && \
    echo 'Name=Google Chrome' >> /home/temple/.local/share/applications/chrome.desktop && \
    echo 'Exec=/usr/local/bin/chrome %U' >> /home/temple/.local/share/applications/chrome.desktop && \
    echo 'Icon=google-chrome' >> /home/temple/.local/share/applications/chrome.desktop && \
    echo 'Terminal=false' >> /home/temple/.local/share/applications/chrome.desktop && \
    echo 'Categories=Network;WebBrowser;' >> /home/temple/.local/share/applications/chrome.desktop && \
    echo 'MimeType=text/html;x-scheme-handler/http;x-scheme-handler/https;' >> /home/temple/.local/share/applications/chrome.desktop && \
    chown -R temple:temple /home/temple/.local/share/applications

# ============================================
# 8. Create desktop shortcuts for browsers
# ============================================
RUN mkdir -p /home/temple/Desktop && \
    echo '[Desktop Entry]' > /home/temple/Desktop/chrome.desktop && \
    echo 'Version=1.0' >> /home/temple/Desktop/chrome.desktop && \
    echo 'Type=Application' >> /home/temple/Desktop/chrome.desktop && \
    echo 'Name=Google Chrome' >> /home/temple/Desktop/chrome.desktop && \
    echo 'Exec=/usr/local/bin/chrome %U' >> /home/temple/Desktop/chrome.desktop && \
    echo 'Icon=google-chrome' >> /home/temple/Desktop/chrome.desktop && \
    echo 'Terminal=false' >> /home/temple/Desktop/chrome.desktop && \
    echo 'Categories=Network;WebBrowser;' >> /home/temple/Desktop/chrome.desktop && \
    chmod +x /home/temple/Desktop/chrome.desktop && \
    echo '[Desktop Entry]' > /home/temple/Desktop/firefox.desktop && \
    echo 'Version=1.0' >> /home/temple/Desktop/firefox.desktop && \
    echo 'Type=Application' >> /home/temple/Desktop/firefox.desktop && \
    echo 'Name=Firefox ESR' >> /home/temple/Desktop/firefox.desktop && \
    echo 'Exec=firefox-esr %U' >> /home/temple/Desktop/firefox.desktop && \
    echo 'Icon=firefox-esr' >> /home/temple/Desktop/firefox.desktop && \
    echo 'Terminal=false' >> /home/temple/Desktop/firefox.desktop && \
    echo 'Categories=Network;WebBrowser;' >> /home/temple/Desktop/firefox.desktop && \
    chmod +x /home/temple/Desktop/firefox.desktop && \
    chown -R temple:temple /home/temple/Desktop

# ============================================
# 9. Configure KasmVNC for ubuntu user
# ============================================
RUN mkdir -p /home/temple/.vnc && \
    echo "xfce" > /home/temple/.vnc/de && \
    echo '#!/bin/bash' > /home/temple/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /home/temple/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /home/temple/.vnc/xstartup && \
    echo 'export XDG_SESSION_TYPE=x11' >> /home/temple/.vnc/xstartup && \
    echo 'exec startxfce4' >> /home/temple/.vnc/xstartup && \
    chmod +x /home/temple/.vnc/xstartup && \
    touch /home/temple/.Xauthority && \
    chown -R temple:temple /home/temple

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
# 12. SSH config - public key only (no password), disable root login
# ============================================
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# ============================================
# 12b. Setup SSH authorized keys for temple user
# ============================================
RUN mkdir -p /home/temple/.ssh && \
    chmod 700 /home/temple/.ssh && \
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfsqGnzHpkyEwfpA77IRpM7L8Olv0GS5rKn+vSSgt2lavCnW6GIZ4sgJYRVcNAZj+JQeAPFjCLbKBqBQtG49PqMKMTGPkQY2ey6mbjO8VDEqBOClVyUroWweszh2OzYeKNIqAkhsh0NisQZytKpEPXDygkWG6inPaME1QeIe+/lcsWfsOhC4J4WcG1QiH46sq78hf7vwM5Em4iHoi9Eofbx2kKSlv7G8rpJj0CkPuYUSw7SLkFwYxR8sTmy+BsBJc6MoZ0IsfTLD3Qd4CSmCc2jEhAEsOuIoQSKKsXfUDguEIF1kVP5OUC8K40ZV+ixNjkMWQfMFPkEnbN5lL9KYof default-rsa-key-1" > /home/temple/.ssh/authorized_keys && \
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDnLbpUAfFJSCJNtozZJP4iKdXxJ/Q/+bDoVFY5erzdUQfPGoxcOHRdEgmN6DbJHNE8uEOFU61qV9M0mB++kTnUb+FSPnFyf0ga6rG/80pknWDXRfI7BBTKCCbiRDt6poaCb5u9+ACNQVWlE5QZqqfgWgE6J7oaLN/yXPPFV9GYyFuVbRuSOAE+b3K4zTIQE2gYFCr2m7dL0LDjqF+VpOyOHSaX7mWDes61hfrBfNZc0s9UcMQsBMJXLPr/cqOt63rEJeHZAxv5Nz3MrtJyyBaCjZdPG8N6GTpEv8aVuaJ7warlfKopJk7gleTCVlCbBCXqj92x8HxFux0jcQhEMvFv default-rsa-key-2" >> /home/temple/.ssh/authorized_keys && \
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEXRZki8xRY4FLdp16PrHWsqr8nbVlYJrqy7qF2pFWO default-ed25519-key" >> /home/temple/.ssh/authorized_keys && \
    chmod 600 /home/temple/.ssh/authorized_keys && \
    chown -R temple:temple /home/temple/.ssh

# ============================================
# 12c. Configure fcitx5 autostart and input methods
# ============================================
RUN mkdir -p /home/temple/.config/autostart && \
    echo '[Desktop Entry]' > /home/temple/.config/autostart/fcitx5.desktop && \
    echo 'Name=Fcitx 5' >> /home/temple/.config/autostart/fcitx5.desktop && \
    echo 'GenericName=Input Method' >> /home/temple/.config/autostart/fcitx5.desktop && \
    echo 'Exec=fcitx5' >> /home/temple/.config/autostart/fcitx5.desktop && \
    echo 'Terminal=false' >> /home/temple/.config/autostart/fcitx5.desktop && \
    echo 'Type=Application' >> /home/temple/.config/autostart/fcitx5.desktop && \
    echo 'Categories=System;Utility;' >> /home/temple/.config/autostart/fcitx5.desktop && \
    mkdir -p /home/temple/.config/fcitx5/profile && \
    echo '[Groups/0]' > /home/temple/.config/fcitx5/profile/default && \
    echo 'Name=Default' >> /home/temple/.config/fcitx5/profile/default && \
    echo 'Default Layout=us' >> /home/temple/.config/fcitx5/profile/default && \
    echo 'DefaultIM=pinyin' >> /home/temple/.config/fcitx5/profile/default && \
    echo '' >> /home/temple/.config/fcitx5/profile/default && \
    echo '[Groups/0/Items/0]' >> /home/temple/.config/fcitx5/profile/default && \
    echo 'Name=keyboard-us' >> /home/temple/.config/fcitx5/profile/default && \
    echo 'Layout=' >> /home/temple/.config/fcitx5/profile/default && \
    echo '' >> /home/temple/.config/fcitx5/profile/default && \
    echo '[Groups/0/Items/1]' >> /home/temple/.config/fcitx5/profile/default && \
    echo 'Name=pinyin' >> /home/temple/.config/fcitx5/profile/default && \
    echo 'Layout=' >> /home/temple/.config/fcitx5/profile/default && \
    echo '' >> /home/temple/.config/fcitx5/profile/default && \
    echo '[Groups/0/Items/2]' >> /home/temple/.config/fcitx5/profile/default && \
    echo 'Name=wubi' >> /home/temple/.config/fcitx5/profile/default && \
    echo 'Layout=' >> /home/temple/.config/fcitx5/profile/default && \
    echo '' >> /home/temple/.config/fcitx5/profile/default && \
    echo '[GroupOrder]' >> /home/temple/.config/fcitx5/profile/default && \
    echo '0=Default' >> /home/temple/.config/fcitx5/profile/default && \
    chown -R temple:temple /home/temple/.config/autostart /home/temple/.config/fcitx5

# ============================================
# 13. Install Claude Code (native installer)
# ============================================
RUN curl -fsSL https://claude.ai/install.sh | bash

# ============================================
# 14. Entrypoint
# ============================================
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 6901 51200-51239

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s \
    CMD pgrep -f kasmvncserver || exit 1

USER temple
WORKDIR /home/temple

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
