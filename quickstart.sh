#!/bin/bash
# Quickstart script for Temple Desktop Development Environment
# Usage: ./quickstart.sh [instance-name] [vnc-port] [ssh-port]

set -e

IMAGE="canadianbitcoin/temple-desktop-dev:latest"
INSTANCE_NAME="${1:-temple-desktop}"
VNC_PORT="${2:-16901}"
SSH_PORT="${3:-10022}"
PASSWORD="${PASSWORD:-temple}"

echo "========================================"
echo "Temple Desktop Dev - Quickstart"
echo "========================================"
echo "Image: $IMAGE"
echo "Instance: $INSTANCE_NAME"
echo "VNC Port: $VNC_PORT"
echo "SSH Port: $SSH_PORT"
echo "========================================"

# Pull latest image
echo "Pulling latest image..."
docker pull $IMAGE

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${INSTANCE_NAME}$"; then
    echo "Container '$INSTANCE_NAME' already exists."
    read -p "Remove and recreate? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker rm -f $INSTANCE_NAME
    else
        echo "Aborted."
        exit 1
    fi
fi

# Create and start container
echo "Creating container..."
mkdir -p ./docker-data/home ./docker-data/docker
docker run -d \
    --name $INSTANCE_NAME \
    --restart unless-stopped \
    --privileged \
    --shm-size 2gb \
    -p ${SSH_PORT}:22 \
    -p ${VNC_PORT}:6901 \
    -e PASSWORD=$PASSWORD \
    -e VNC_PASSWORD=$PASSWORD \
    -e TZ=Asia/Shanghai \
    -v $(pwd)/docker-data/home:/home/temple \
    -v $(pwd)/docker-data/docker:/var/lib/docker \
    $IMAGE

echo ""
echo "========================================"
echo "Container '$INSTANCE_NAME' started!"
echo "========================================"
echo "Web VNC: https://localhost:${VNC_PORT}"
echo "SSH:     ssh temple@localhost -p ${SSH_PORT}"
echo "User:    temple"
echo "Password: $PASSWORD"
echo ""
echo "⚠️  SECURITY: Change default passwords!"
echo "   docker exec -it $INSTANCE_NAME vncpasswd"
echo "   docker exec -it $INSTANCE_NAME sh -c 'echo temple:新密码 | chpasswd'"
echo ""
echo "Data:    $(pwd)/docker-data/"
echo "  To change storage location, edit the -v paths above"
echo "========================================"
echo ""
echo "Attach to Claude Code session:"
echo "  ssh temple@localhost -p ${SSH_PORT}"
echo "  (auto-attaches to tmux dev session)"
echo ""
echo "Or manually:"
echo "  docker exec -it $INSTANCE_NAME tmux attach -t dev"
echo "========================================"
