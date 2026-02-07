#!/bin/bash
# ============================================
# Build Docker image with CUDA support
# ============================================
# Usage:
#   ./build-cuda.sh              # Use default CUDA 12.6.2
#   ./build-cuda.sh 12.4.1       # Use specific CUDA version
#   ./build-cuda.sh 11.8.0       # Use older CUDA version
#
# Supported CUDA versions for Ubuntu 24.04:
#   12.6.2, 12.5.1, 12.4.1, 12.3.2, 12.2.2, 12.1.1, 12.0.1
#
# Full list: https://hub.docker.com/r/nvidia/cuda/tags?page=1&name=ubuntu24.04
# ============================================

set -e

CUDA_VERSION=${1:-12.6.2}
UBUNTU_VERSION=24.04
BASE_IMAGE="nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}"
TAG="temple-desktop:cuda-${CUDA_VERSION}"

echo "=========================================="
echo "Building with CUDA ${CUDA_VERSION}"
echo "Base image: ${BASE_IMAGE}"
echo "Output tag: ${TAG}"
echo "=========================================="

# Pull base image first
echo "Pulling base image..."
docker pull ${BASE_IMAGE}

# Build the image
echo "Building Docker image..."
docker build \
    --build-arg BASE_IMAGE=${BASE_IMAGE} \
    -t ${TAG} \
    -t temple-desktop:cuda-latest \
    .

echo "=========================================="
echo "Build complete!"
echo "Image: ${TAG}"
echo ""
echo "Run with:"
echo "  docker compose -f docker-compose.yml -f docker-compose.cuda.yml up -d"
echo ""
echo "Or manually:"
echo "  docker run -d --gpus all -p 16901:6901 -p 10022:22 ${TAG}"
echo "=========================================="
