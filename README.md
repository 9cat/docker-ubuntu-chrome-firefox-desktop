# Ubuntu Desktop Development Environment

[![Docker Hub](https://img.shields.io/docker/pulls/canadianbitcoin/dev-desktop)](https://hub.docker.com/r/canadianbitcoin/dev-desktop)

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

### Option 1: Pre-built Image (Recommended)

```bash
cat > docker-compose.yml << 'EOF'
services:
  desktop:
    image: canadianbitcoin/dev-desktop:latest
    container_name: temple-desktop
    restart: unless-stopped
    ports:
      - "10022:22"
      - "16901:6901"
    environment:
      - PASSWORD=temple
      - VNC_PASSWORD=temple
      - TZ=Asia/Shanghai
    volumes:
      - desktop-data:/home/temple
      - /var/run/docker.sock:/var/run/docker.sock
    shm_size: 2gb

volumes:
  desktop-data:
EOF

docker compose up -d
```

### Option 2: Build from Source

```bash
git clone https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop.git
cd docker-ubuntu-chrome-firefox-desktop
docker compose up -d --build
```

## Access

| Service | URL | Credentials |
|---------|-----|-------------|
| Web Desktop | https://localhost:16901 | temple / temple |
| SSH | `ssh temple@localhost -p 10022` | SSH key only |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PASSWORD` | temple | VNC web password |
| `VNC_PASSWORD` | temple | VNC login password |
| `TZ` | Asia/Shanghai | Timezone |
| `SSH_PUBLIC_KEY` | (built-in) | SSH public key for authentication |

### SSH Configuration

SSH uses **public key authentication only**. To use your own key:

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
# SSH into container
ssh temple@localhost -p 10022

# Attach to tmux session (Claude Code is already running)
tmux attach -t dev
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

Docker CLI and Compose are pre-installed. By default, the host's Docker socket is mounted:

```bash
docker ps              # List containers
docker run hello-world # Run container
```

For isolated Docker daemon, enable privileged mode and run `sudo dockerd &`.

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
