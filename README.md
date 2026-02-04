# Ubuntu Desktop Development Environment

[![Docker Hub](https://img.shields.io/docker/pulls/canadianbitcoin/temple-desktop-dev)](https://hub.docker.com/r/canadianbitcoin/temple-desktop-dev)

Minimal Ubuntu Desktop environment with Chrome, Firefox, Claude Code, and KasmVNC for remote development.

[中文文档](README_zh.md)

## Features

- **Ubuntu 24.04** base image
- **XFCE4** lightweight desktop environment
- **KasmVNC** web-based remote desktop (HTTPS)
- **Chrome** + **Firefox ESR** browsers (Chrome as default)
- **Claude Code** - Anthropic's AI coding assistant with auto-start
- **tmux session** - Pre-configured dev session for SSH development
- **Docker-in-Docker** - Create and manage containers from within
- **Chinese support** - Fonts and input methods (Pinyin + Wubi)
- **Auto-trusted SSL certificates** - No browser warnings
- **SSH public key authentication** - Secure access

## Quick Start

### Option 1: One-Line Docker Run (Fastest)

```bash
docker run -d --name temple-desktop --privileged --shm-size 2gb \
  -p 10022:22 -p 16901:6901 \
  -e PASSWORD=temple -e VNC_PASSWORD=temple \
  canadianbitcoin/temple-desktop-dev:latest
```

### Option 2: Quickstart Script

```bash
curl -fsSL https://raw.githubusercontent.com/9cat/docker-ubuntu-chrome-firefox-desktop/main/quickstart.sh | bash
```

Or with custom settings:

```bash
# Download and run with custom name/ports
curl -fsSL https://raw.githubusercontent.com/9cat/docker-ubuntu-chrome-firefox-desktop/main/quickstart.sh -o quickstart.sh
chmod +x quickstart.sh
./quickstart.sh my-desktop 16902 10023  # [instance-name] [vnc-port] [ssh-port]
```

### Option 3: Docker Compose

```bash
git clone https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop.git
cd docker-ubuntu-chrome-firefox-desktop
docker compose up -d
```

### Option 4: Inline Docker Compose

```bash
cat > docker-compose.yml << 'EOF'
services:
  desktop:
    image: canadianbitcoin/temple-desktop-dev:latest
    container_name: temple-desktop
    restart: unless-stopped
    privileged: true
    shm_size: 2gb
    ports:
      - "10022:22"
      - "16901:6901"
    environment:
      - PASSWORD=temple
      - VNC_PASSWORD=temple
      - TZ=Asia/Shanghai
    volumes:
      - desktop-data:/home/temple
      - docker-data:/var/lib/docker

volumes:
  desktop-data:
  docker-data:
EOF

docker compose up -d
```

## Running Multiple Instances

Create additional instances with different ports:

```bash
# Instance 2
docker run -d --name temple-desktop-2 --privileged --shm-size 2gb \
  -p 10023:22 -p 16902:6901 \
  -v temple-desktop-2-data:/home/temple \
  -v temple-desktop-2-docker:/var/lib/docker \
  -e PASSWORD=temple -e VNC_PASSWORD=temple \
  canadianbitcoin/temple-desktop-dev:latest

# Instance 3
docker run -d --name temple-desktop-3 --privileged --shm-size 2gb \
  -p 10024:22 -p 16903:6901 \
  -v temple-desktop-3-data:/home/temple \
  -v temple-desktop-3-docker:/var/lib/docker \
  -e PASSWORD=temple -e VNC_PASSWORD=temple \
  canadianbitcoin/temple-desktop-dev:latest
```

Or use the quickstart script:

```bash
./quickstart.sh desktop-2 16902 10023
./quickstart.sh desktop-3 16903 10024
```

## Access

| Service | URL | Credentials |
|---------|-----|-------------|
| Web Desktop | https://localhost:16901 | temple / temple |
| SSH | `ssh temple@localhost -p 10022` | SSH key or password |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PASSWORD` | temple | Linux user password |
| `VNC_PASSWORD` | temple | VNC login password |
| `TZ` | Asia/Shanghai | Timezone |
| `SSH_PUBLIC_KEY` | (built-in) | SSH public key for authentication |

### SSH Configuration

SSH supports both password and public key authentication. To use your own key:

```yaml
environment:
  - SSH_PUBLIC_KEY=ssh-rsa AAAA... your-key-comment
```

Or mount your authorized_keys file:

```yaml
volumes:
  - ./authorized_keys:/home/temple/.ssh/authorized_keys:ro
```

## Claude Code

Claude Code starts automatically in a tmux session when the container boots.

```bash
# SSH into container (auto-attaches to tmux)
ssh temple@localhost -p 10022

# Or manually attach
docker exec -it temple-desktop tmux attach -t dev
```

### tmux Windows

| Window | Name | Purpose |
|--------|------|---------|
| 0 | claude | Claude Code (auto-started) |
| 1 | shell | General shell |

### tmux Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+b d` | Detach |
| `Ctrl+b n` | Next window |
| `Ctrl+b p` | Previous window |

### API Key

Set your Anthropic API key:

```bash
echo 'export ANTHROPIC_API_KEY=your-key' >> ~/.bashrc
```

## Chinese Input

Chinese fonts and input methods (fcitx5) are pre-installed:

- **Pinyin** (拼音)
- **Wubi** (五笔)

| Shortcut | Action |
|----------|--------|
| `Ctrl+Space` | Toggle Chinese/English |
| `Ctrl+Shift` | Switch Pinyin/Wubi |

## Docker-in-Docker

True Docker-in-Docker is enabled by default. The container runs its own isolated Docker daemon:

```bash
docker ps              # List containers (inside this container)
docker run hello-world # Run container (isolated from host)
```

Containers created inside are completely isolated from the host. Ports 51200-51239 are mapped for inner container services.

To switch to Docker-outside-of-Docker (share host's Docker), edit `docker-compose.yml`:
```yaml
privileged: false
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

## Management

```bash
docker compose up -d          # Start
docker compose down           # Stop
docker compose logs -f        # Logs
docker compose up -d --build  # Rebuild
docker compose down -v        # Reset all data
```

## Ports

| Port | Service |
|------|---------|
| 22 | SSH |
| 6901 | KasmVNC (HTTPS) |

## License

MIT

## Author

temple <temple@iobond.com>
