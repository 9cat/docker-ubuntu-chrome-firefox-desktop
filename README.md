# Ubuntu Desktop Development Environment

[![Docker Hub](https://img.shields.io/docker/pulls/canadianbitcoin/temple-desktop-dev)](https://hub.docker.com/r/canadianbitcoin/temple-desktop-dev)
[![GitHub](https://img.shields.io/badge/GitHub-9cat%2Fdocker--ubuntu--chrome--firefox--desktop-blue)](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop)

Minimal Ubuntu Desktop environment with Chrome, Firefox, Claude Code, KasmVNC, and optional **NVIDIA CUDA/GPU acceleration** for remote development.

[中文文档](README_zh.md) | [CUDA Documentation](CUDA.md)

---

## Release Notes

| Version | Date | Changes |
|---------|------|---------|
| v1.1 | 2025-02-09 | Bind mount storage, home dir ownership fix, skeleton files, stop scripts |
| v1.0 | 2025-02-08 | CUDA/OpenGL/Vulkan GPU acceleration, VirtualGL |
| v0.6 | - | Docker-in-Docker, Chinese input, Claude Code auto-start |

### v1.1 — What Changed

- **Storage: local bind mount `./docker-data/`** — No longer uses Docker named volumes in `/var/lib/docker/volumes/`. Data lives next to the project for easier backup, migration, and disk management
- **Fix: home directory ownership** — `chown temple:temple /home/temple` on startup prevents permission errors when bind mount creates root-owned directory
- **Fix: skeleton .bashrc/.profile** — Copies `/etc/skel` files on first boot so SSH login auto-attaches to tmux dev session
- **Fix: VirtualGL build** — Added missing `libglu1-mesa` dependency
- **Add: stop scripts** — `stop_desktop.sh` / `stop_cuda_desktop.sh` with `clean` and `purge` options
- **Add: one-click CUDA deployment** — `start_cuda_desktop.sh` automates driver check, toolkit install, build, and launch

---

## Features

### Base
- **Ubuntu 24.04** base image
- **XFCE4** lightweight desktop environment
- **KasmVNC** web-based remote desktop (HTTPS)
- **Chrome** + **Firefox ESR** browsers
- **Claude Code** - Anthropic's AI coding assistant (auto-starts in tmux)
- **Docker-in-Docker** - Isolated Docker daemon inside container
- **Chinese support** - Fonts and input methods (Pinyin + Wubi)
- **SSH key authentication** - Secure access

### CUDA/GPU (Optional)
- **NVIDIA CUDA Toolkit** - Deep learning, GPU computing
- **OpenGL/EGL** - Hardware-accelerated 3D rendering via VirtualGL
- **Vulkan** - Modern GPU graphics API
- **Flexible CUDA versions** - Support for CUDA 11.x and 12.x

---

## Quick Start

### Standard (No GPU)

```bash
git clone https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop.git
cd docker-ubuntu-chrome-firefox-desktop
docker compose up -d --build
```

Or use the quickstart script:

```bash
./quickstart.sh
```

### With CUDA/GPU Support

```bash
./start_cuda_desktop.sh
```

Or manually:

```bash
docker compose -f docker-compose.yml -f docker-compose.cuda.yml build
docker compose -f docker-compose.yml -f docker-compose.cuda.yml up -d
```

See [CUDA.md](CUDA.md) for prerequisites (NVIDIA driver + container toolkit).

---

## Access

| Service | URL | Credentials |
|---------|-----|-------------|
| Web Desktop | https://localhost:16901 | temple / temple |
| SSH | `ssh temple@localhost -p 10022` | SSH key |

---

## Data Storage

Data is stored in `./docker-data/` (bind mount), **not** in `/var/lib/docker/volumes/`:

```
./docker-data/
├── home/     User data (/home/temple)
└── docker/   Docker-in-Docker data
```

To change storage location, edit the volume paths in `docker-compose.yml`.

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PASSWORD` | temple | Linux user password |
| `VNC_PASSWORD` | temple | VNC login password |
| `TZ` | Asia/Shanghai | Timezone |
| `SSH_PUBLIC_KEY` | (built-in keys) | Custom SSH public key |
| `NVIDIA_VISIBLE_DEVICES` | all | GPU visibility (CUDA only) |
| `NVIDIA_DRIVER_CAPABILITIES` | all | GPU capabilities (CUDA only) |

---

## Management

```bash
# Standard
docker compose up -d --build          # Start
docker compose down                   # Stop (keep data)
./stop_desktop.sh                     # Stop
./stop_desktop.sh clean               # Stop + delete data
./stop_desktop.sh purge               # Stop + delete data + images

# CUDA version
docker compose -f docker-compose.yml -f docker-compose.cuda.yml up -d
./stop_cuda_desktop.sh [clean|purge]

# Logs
docker compose logs -f

# Verify GPU
docker exec -it temple-desktop nvidia-smi
docker exec -it temple-desktop nvcc --version
```

---

## CUDA Details

### Supported Versions

| Ubuntu | CUDA Versions |
|--------|---------------|
| 24.04 | 12.6.2, 12.5.1, 12.4.1, 12.3.2 |

### Driver Compatibility

| CUDA | Minimum Driver |
|------|----------------|
| 12.6 | 560.28+ |
| 12.4 | 550.54+ |
| 12.2 | 535.86+ |
| 11.8 | 520.61+ |

Full list: https://hub.docker.com/r/nvidia/cuda/tags

---

## Branches

| Branch | Description | Link |
|--------|-------------|------|
| `main` | Full desktop + CUDA support (this branch) | [main](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop) |
| `cuda-support` | CUDA development branch | [cuda-support](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop/tree/cuda-support) |
| `android-support` | Android Emulator + automation | [android-support](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop/tree/android-support) |

---

## License

MIT

## Author

temple <temple@iobond.com>
