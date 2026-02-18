#!/bin/bash
# ============================================
# temple-desktop-dev 镜像部署脚本
# 用于从 tar.gz 文件加载并启动容器
# ============================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 默认值
IMAGE_TAR="${SCRIPT_DIR}/temple-desktop-dev-latest.tar.gz"
IMAGE_NAME="canadianbitcoin/temple-desktop-dev:latest"
CONTAINER_NAME="temple-desktop"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            IMAGE_TAR="$2"
            shift 2
            ;;
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  -f, --file FILE    指定镜像tar.gz文件路径 (默认: ./temple-desktop-dev-latest.tar.gz)"
            echo "  -n, --name NAME    指定镜像名称 (默认: canadianbitcoin/temple-desktop-dev:latest)"
            echo "  -h, --help         显示此帮助信息"
            exit 0
            ;;
        *)
            error "未知选项: $1 (使用 -h 查看帮助)"
            ;;
    esac
done

info "========================================="
info "temple-desktop-dev 镜像部署"
info "========================================="
info "镜像文件: $IMAGE_TAR"
info "镜像名称: $IMAGE_NAME"
info "========================================="

# 检查文件是否存在
if [ ! -f "$IMAGE_TAR" ]; then
    error "镜像文件不存在: $IMAGE_TAR"
fi

# 显示文件大小
FILE_SIZE=$(ls -lh "$IMAGE_TAR" | awk '{print $5}')
info "文件大小: $FILE_SIZE"

# 停止并删除现有容器（如果存在）
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    warn "发现现有容器 $CONTAINER_NAME，正在停止并删除..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
fi

# 检查镜像是否已存在
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}$"; then
    warn "镜像 $IMAGE_NAME 已存在，正在删除..."
    docker rmi "$IMAGE_NAME" 2>/dev/null || true
fi

# 加载镜像
info "正在加载镜像（可能需要几分钟）..."
time docker load -i "$IMAGE_TAR" || error "镜像加载失败"

# 验证镜像
info "验证镜像..."
if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}$"; then
    error "镜像加载后未找到: $IMAGE_NAME"
fi

# 显示镜像信息
IMAGE_SIZE=$(docker images "$IMAGE_NAME" --format '{{.Size}}')
info "镜像加载成功！大小: $IMAGE_SIZE"

info "========================================="
info "镜像已准备就绪"
info "========================================="
info ""
info "要启动容器，请运行:"
info ""
info "  docker run -d \\"
info "    --name $CONTAINER_NAME \\"
info "    --restart unless-stopped \\"
info "    -p 10022:22 \\"
info "    -p 16901:6901 \\"
info "    -p 51200-51239:51200-51239 \\"
info "    --privileged \\"
info "    --shm-size=2gb \\"
info "    -v \$(pwd)/docker-data/home:/home/temple \\"
info "    -v \$(pwd)/docker-data/docker:/var/lib/docker \\"
info "    -e PASSWORD=temple \\"
info "    -e VNC_PASSWORD=temple \\"
info "    -e TZ=Asia/Shanghai \\"
info "    $IMAGE_NAME"
info ""
info "或使用 docker-compose (如果有 docker-compose.yml):"
info ""
info "  docker compose up -d"
info ""
info "访问方式:"
info "  Web桌面: https://localhost:16901 (temple/temple)"
info "  SSH: ssh temple@localhost -p 10022"
info ""
