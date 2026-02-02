# Ubuntu Desktop Development Environment

Minimal Ubuntu Desktop environment with Chrome + Firefox + KasmVNC for remote browser access.

极简的 Ubuntu 桌面开发环境，包含 Chrome + Firefox + KasmVNC。

## Features

- **Ubuntu 24.04** base image
- **XFCE4** lightweight desktop environment
- **KasmVNC** web-based remote desktop (HTTPS)
- **Chrome** + **Firefox ESR** browsers pre-installed
- **Claude Code** - Anthropic's AI coding assistant pre-installed
- **tmux session** - Auto-started dev session for SSH development
- **Docker-in-Docker** - create and manage containers from within
- **Auto-trusted SSL certificates** - no browser warnings
- **SSH access** for terminal operations
- **Persistent storage** via Docker volumes

## Quick Start

### Option 1: Use pre-built image from Docker Hub (Recommended)

The fastest way - no build required, all dependencies pre-installed:

```bash
# Create docker-compose.yml
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

# Start the container
docker compose up -d
```

**Available tags:**
- `canadianbitcoin/dev-desktop:latest` - Latest stable release
- `canadianbitcoin/dev-desktop:0.6` - Version 0.6

### Option 2: Build from source

If you need to customize the image or prefer building locally:

```bash
git clone https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop.git
cd docker-ubuntu-chrome-firefox-desktop
docker compose up -d --build
```

## Access

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| **Web Desktop** | https://localhost:16901 | temple / temple |
| **SSH** | `ssh temple@localhost -p 10022` | temple / temple |

> **Note**: CA certificate is automatically installed in Chrome and Firefox inside the container. No manual certificate import needed.

## Port Configuration

| Port | Service | Description |
|------|---------|-------------|
| `22` | SSH | Secure shell access |
| `6901` | KasmVNC | Web-based VNC (HTTPS) |
| `51200-51239` | Reserved | Additional services (optional) |

### Custom Ports

Edit `docker-compose.yml` to change port mappings:

```yaml
ports:
  - "2222:22"      # SSH on port 2222
  - "8443:6901"    # VNC on port 8443
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `USER` | temple | System username |
| `PASSWORD` | temple | System & SSH password |
| `VNC_PASSWORD` | temple | VNC login password |
| `TZ` | Asia/Shanghai | Timezone |

### Custom Credentials

Create a `.env` file:

```bash
PASSWORD=mysecretpassword
VNC_PASSWORD=mysecretpassword
TZ=America/New_York
```

Or set directly in `docker-compose.yml`:

```yaml
environment:
  - PASSWORD=mysecretpassword
  - VNC_PASSWORD=mysecretpassword
```

## Management Commands

```bash
# Start
docker compose up -d

# Stop
docker compose down

# View logs
docker compose logs -f

# Rebuild (after updates)
docker compose up -d --build

# Enter container shell
docker exec -it temple-desktop bash

# Reset (delete all data)
docker compose down -v
```

## Browser Usage

Both browsers are accessible from the desktop:

- **Chrome**: Click the Chrome icon or run `/usr/local/bin/chrome`
- **Firefox**: Click the Firefox icon or run `firefox-esr`

Chrome runs with `--no-sandbox` flag (required for Docker).

## Claude Code Development

[Claude Code](https://github.com/anthropics/claude-code) is Anthropic's official CLI for AI-assisted coding. It comes pre-installed and ready to use.

### Getting Started

1. SSH into the container:
   ```bash
   ssh temple@localhost -p 10022
   ```

2. Attach to the pre-created tmux session:
   ```bash
   tmux attach -t dev
   ```

3. Start Claude Code (requires API key):
   ```bash
   export ANTHROPIC_API_KEY=your-api-key
   claude
   ```

### tmux Session

A tmux session named `dev` is automatically created on container startup with two windows:

| Window | Name | Purpose |
|--------|------|---------|
| 0 | claude | Claude Code development |
| 1 | shell | General shell tasks |

### tmux Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+b d` | Detach from session |
| `Ctrl+b n` | Next window |
| `Ctrl+b p` | Previous window |
| `Ctrl+b c` | Create new window |
| `Ctrl+b 0-9` | Switch to window by number |

### Persistent API Key

To avoid setting the API key every time, add it to your `.bashrc`:

```bash
echo 'export ANTHROPIC_API_KEY=your-api-key' >> ~/.bashrc
```

## Docker-in-Docker

This container supports running Docker commands and creating containers from within. Docker CLI and Docker Compose are pre-installed.

### Default Mode: Socket Mounting

By default, the container mounts the host's Docker socket (`/var/run/docker.sock`). This allows you to:

```bash
# Inside the container
docker ps                    # List host's containers
docker run hello-world       # Run a container (on host)
docker compose up -d         # Use docker compose
```

> **Note**: Containers created this way run on the host, not inside this container.

### Isolated Mode: True DinD

For complete isolation (separate Docker daemon), enable privileged mode in `docker-compose.yml`:

```yaml
services:
  desktop:
    privileged: true
    # Remove or comment out the socket mount:
    # - /var/run/docker.sock:/var/run/docker.sock
```

Then start dockerd manually inside the container:

```bash
sudo dockerd &
docker ps    # Now using isolated Docker daemon
```

### Docker Usage Examples

```bash
# Pull and run an image
docker pull nginx
docker run -d -p 8080:80 nginx

# Build from Dockerfile
docker build -t myapp .

# Docker Compose
docker compose up -d

# Check Docker version
docker --version
docker compose version
```

## Security Notes

- Default passwords should be changed for production use
- The container generates self-signed CA certificates for HTTPS
- CA is automatically trusted by browsers inside the container
- External browsers will show certificate warnings (expected)

## Troubleshooting

### Cannot connect to VNC
```bash
# Check if container is running
docker ps

# Check logs
docker compose logs -f
```

### Browser won't start
```bash
# SSH into container and check
docker exec -it temple-desktop bash
chrome --version
firefox-esr --version
```

### Reset to clean state
```bash
docker compose down -v
docker compose up -d --build
```

## License

MIT

## Author

temple <temple@iobond.com>
