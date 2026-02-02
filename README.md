# Ubuntu Desktop Development Environment

Minimal Ubuntu Desktop environment with Chrome + Firefox + KasmVNC for remote browser access.

极简的 Ubuntu 桌面开发环境，包含 Chrome + Firefox + KasmVNC。

## Features

- **Ubuntu 24.04** base image
- **XFCE4** lightweight desktop environment
- **KasmVNC** web-based remote desktop (HTTPS)
- **Chrome** + **Firefox ESR** browsers pre-installed
- **Docker-in-Docker** - create and manage containers from within
- **Auto-trusted SSL certificates** - no browser warnings
- **SSH access** for terminal operations
- **Persistent storage** via Docker volumes

## Quick Start

### Option 1: Build from source

```bash
git clone https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop.git
cd docker-ubuntu-chrome-firefox-desktop
docker compose up -d --build
```

### Option 2: Use pre-built image

```yaml
# docker-compose.yml
services:
  desktop:
    image: ghcr.io/9cat/docker-ubuntu-chrome-firefox-desktop:latest
    container_name: ubuntu-desktop
    restart: unless-stopped
    ports:
      - "10022:22"     # SSH
      - "16901:6901"   # KasmVNC Web
    environment:
      - PASSWORD=ubuntu
      - VNC_PASSWORD=ubuntu
      - TZ=Asia/Shanghai
    volumes:
      - desktop-data:/home/ubuntu

volumes:
  desktop-data:
```

## Access

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| **Web Desktop** | https://localhost:16901 | ubuntu / ubuntu |
| **SSH** | `ssh ubuntu@localhost -p 10022` | ubuntu / ubuntu |

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
| `USER` | ubuntu | System username |
| `PASSWORD` | ubuntu | System & SSH password |
| `VNC_PASSWORD` | ubuntu | VNC login password |
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
docker exec -it ubuntu-desktop bash

# Reset (delete all data)
docker compose down -v
```

## Browser Usage

Both browsers are accessible from the desktop:

- **Chrome**: Click the Chrome icon or run `/usr/local/bin/chrome`
- **Firefox**: Click the Firefox icon or run `firefox-esr`

Chrome runs with `--no-sandbox` flag (required for Docker).

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
docker exec -it ubuntu-desktop bash
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
