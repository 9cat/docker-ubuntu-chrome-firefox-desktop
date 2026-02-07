# Ubuntu Desktop Development Environment

[![Docker Hub](https://img.shields.io/docker/pulls/canadianbitcoin/temple-desktop-dev)](https://hub.docker.com/r/canadianbitcoin/temple-desktop-dev)
[![GitHub](https://img.shields.io/badge/GitHub-9cat%2Fdocker--ubuntu--chrome--firefox--desktop-blue)](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop)

Minimal Ubuntu Desktop environment with Chrome, Firefox, Claude Code, KasmVNC, and **NVIDIA CUDA/OpenGL GPU acceleration** for remote development.

[中文文档](README_zh.md) | [CUDA 详细文档](CUDA.md)

---

## Branch: `cuda-support`

This branch adds **NVIDIA CUDA and OpenGL GPU acceleration** support.

### Release Notes

| Version | Date | Changes |
|---------|------|---------|
| cuda-support | 2025-02-08 | Initial CUDA/OpenGL support |

### What's New in This Branch

- **CUDA Support**: Based on `nvidia/cuda` official images for automatic driver compatibility
- **OpenGL Hardware Acceleration**: Via VirtualGL for 3D rendering
- **Vulkan Support**: GPU-accelerated graphics API
- **Flexible CUDA Versions**: Support for CUDA 11.x and 12.x

### Links

| Resource | URL |
|----------|-----|
| This Branch | https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop/tree/cuda-support |
| Main Branch | https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop |
| Android Branch | https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop/tree/android-support |
| Docker Hub | https://hub.docker.com/r/canadianbitcoin/temple-desktop-dev |
| CUDA Documentation | [CUDA.md](CUDA.md) |

---

## Features

### Base Features
- **Ubuntu 24.04** base image
- **XFCE4** lightweight desktop environment
- **KasmVNC** web-based remote desktop (HTTPS)
- **Chrome** + **Firefox ESR** browsers
- **Claude Code** - Anthropic's AI coding assistant
- **Docker-in-Docker** - Container management from within
- **Chinese support** - Fonts and input methods (Pinyin + Wubi)

### CUDA/GPU Features (This Branch)
- **NVIDIA CUDA Toolkit** - For deep learning, GPU computing
- **OpenGL/EGL** - Hardware-accelerated 3D rendering
- **VirtualGL** - Run 3D apps with GPU acceleration
- **Vulkan** - Modern GPU graphics API
- **Automatic Driver Compatibility** - Uses nvidia/cuda base images

---

## Prerequisites (Host Machine)

### 1. NVIDIA Driver

```bash
# Check if installed
nvidia-smi

# Install if needed (Ubuntu)
sudo apt-get update
sudo apt-get install -y nvidia-driver-550
```

### 2. NVIDIA Container Toolkit

```bash
# Add repository
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
    sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Install
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Configure Docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Verify
docker run --rm --gpus all nvidia/cuda:12.6.2-base-ubuntu24.04 nvidia-smi
```

---

## Quick Start (CUDA)

### Option 1: Build Script (Recommended)

```bash
git clone https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop.git
cd docker-ubuntu-chrome-firefox-desktop
git checkout cuda-support

# Build with default CUDA 12.6.2
./build-cuda.sh

# Or specify CUDA version
./build-cuda.sh 12.4.1
./build-cuda.sh 11.8.0

# Run with GPU
docker compose -f docker-compose.yml -f docker-compose.cuda.yml up -d
```

### Option 2: Docker Compose

```bash
git clone https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop.git
cd docker-ubuntu-chrome-firefox-desktop
git checkout cuda-support

# Build and run with GPU
docker compose -f docker-compose.yml -f docker-compose.cuda.yml up -d
```

### Option 3: Manual Docker Run

```bash
# Build
docker build \
    --build-arg BASE_IMAGE=nvidia/cuda:12.6.2-devel-ubuntu24.04 \
    -t temple-desktop:cuda .

# Run
docker run -d --name temple-desktop-cuda \
    --gpus all \
    --privileged \
    --shm-size=2gb \
    -p 16901:6901 \
    -p 10022:22 \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    temple-desktop:cuda
```

---

## Supported CUDA Versions

Based on `nvidia/cuda` official images:

| Ubuntu | CUDA Versions |
|--------|---------------|
| 24.04 | 12.6.2, 12.5.1, 12.4.1, 12.3.2 |
| 22.04 | 12.6.2, 12.5.1, 12.4.1, 11.8.0, 11.7.1 |

Full list: https://hub.docker.com/r/nvidia/cuda/tags

### Driver Compatibility

| CUDA | Minimum Driver |
|------|----------------|
| 12.6 | 560.28+ |
| 12.4 | 550.54+ |
| 12.2 | 535.86+ |
| 11.8 | 520.61+ |

---

## Verify GPU Acceleration

```bash
# Inside container

# Check CUDA
nvidia-smi
nvcc --version

# Check OpenGL (software)
glxinfo | grep "OpenGL renderer"

# Check OpenGL (hardware accelerated)
vglrun glxinfo | grep "OpenGL renderer"
# Should show your NVIDIA GPU

# Check Vulkan
vulkaninfo | grep -i "GPU"

# Run 3D apps with GPU
vglrun glxgears
vglrun blender
```

---

## Access

| Service | URL | Credentials |
|---------|-----|-------------|
| Web Desktop | https://localhost:16901 | temple / temple |
| SSH | `ssh temple@localhost -p 10022` | SSH key or password |

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PASSWORD` | temple | Linux user password |
| `VNC_PASSWORD` | temple | VNC login password |
| `TZ` | Asia/Shanghai | Timezone |
| `NVIDIA_VISIBLE_DEVICES` | all | GPU visibility |
| `NVIDIA_DRIVER_CAPABILITIES` | all | GPU capabilities |

---

## Other Branches

| Branch | Description | Link |
|--------|-------------|------|
| `main` | Base desktop environment | [main](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop) |
| `cuda-support` | CUDA/OpenGL GPU acceleration (this branch) | [cuda-support](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop/tree/cuda-support) |
| `android-support` | Android Emulator + automation tools | [android-support](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop/tree/android-support) |

### Combine CUDA + Android

```bash
git checkout cuda-support
git merge android-support
# Resolve conflicts and build
```

---

## License

MIT

## Author

temple <temple@iobond.com>
