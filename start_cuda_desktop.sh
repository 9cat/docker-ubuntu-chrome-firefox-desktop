#!/bin/bash
# ============================================
# CUDA Desktop 一键启动脚本
# ============================================
# 用法: ./start_cuda_desktop.sh
#   或: curl -fsSL <url>/start_cuda_desktop.sh | bash
#
# 前提: 主机已安装 NVIDIA 驱动 + Docker
# ============================================

set -e

REPO="https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop.git"
BRANCH="cuda-support"
DIR_NAME="docker-ubuntu-chrome-firefox-desktop"

echo "=========================================="
echo "  CUDA Desktop 一键部署"
echo "=========================================="

# 1. 检查 NVIDIA 驱动
echo ""
echo "[1/5] 检查 NVIDIA 驱动..."
if ! command -v nvidia-smi &>/dev/null; then
    echo "❌ 未检测到 nvidia-smi，请先安装 NVIDIA 驱动"
    exit 1
fi
nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
echo "✅ NVIDIA 驱动正常"

# 2. 检查 Docker
echo ""
echo "[2/5] 检查 Docker..."
if ! command -v docker &>/dev/null; then
    echo "❌ 未检测到 Docker，请先安装"
    exit 1
fi
docker --version
echo "✅ Docker 正常"

# 3. 检查/安装 nvidia-container-toolkit
echo ""
echo "[3/5] 检查 nvidia-container-toolkit..."
if ! docker run --rm --gpus all nvidia/cuda:12.6.2-base-ubuntu24.04 nvidia-smi &>/dev/null 2>&1; then
    echo "⚠️  nvidia-container-toolkit 未就绪，正在安装..."
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg 2>/dev/null
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        tee /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null
    apt-get update -qq && apt-get install -y -qq nvidia-container-toolkit
    nvidia-ctk runtime configure --runtime=docker
    systemctl restart docker
    echo "✅ nvidia-container-toolkit 安装完成"
else
    echo "✅ nvidia-container-toolkit 已就绪"
fi

# 4. 克隆/更新仓库
echo ""
echo "[4/5] 准备代码仓库..."
if [ -d "$DIR_NAME" ]; then
    echo "仓库已存在，拉取最新代码..."
    cd "$DIR_NAME"
    git fetch origin && git checkout "$BRANCH" && git pull origin "$BRANCH"
else
    echo "克隆仓库..."
    git clone -b "$BRANCH" "$REPO"
    cd "$DIR_NAME"
fi
echo "✅ 代码就绪 (branch: $BRANCH)"

# 5. 创建数据目录并启动
echo ""
echo "[5/5] 构建 CUDA 镜像并启动..."
mkdir -p ./docker-data/home ./docker-data/docker
docker compose -f docker-compose.yml -f docker-compose.cuda.yml build
docker compose -f docker-compose.yml -f docker-compose.cuda.yml up -d

# 获取实际存储路径
DATA_PATH="$(pwd)/docker-data"

echo ""
echo "=========================================="
echo "  ✅ CUDA Desktop 启动成功！"
echo "=========================================="
echo ""
echo "  VNC 访问:  https://localhost:16901"
echo "  SSH 访问:  ssh temple@localhost -p 10022"
echo "  用户/密码:  temple / temple"
echo ""
echo "  ⚠️  安全提醒: 请立即修改默认密码！"
echo "     VNC:     docker exec -it temple-desktop sh -c 'echo -e \"新密码\\n新密码\" | vncpasswd'"
echo "     系统:    docker exec -it temple-desktop sh -c 'echo temple:新密码 | chpasswd'"
echo ""
echo "  数据存储:  ${DATA_PATH}/"
echo "    ├── home/     用户数据 (/home/temple)"
echo "    └── docker/   Docker-in-Docker 数据"
echo ""
echo "  💡 如需修改存储位置，编辑 docker-compose.yml 中的 volumes:"
echo "     - /your/path/home:/home/temple"
echo "     - /your/path/docker:/var/lib/docker"
echo ""
echo "  查看日志:  docker compose logs -f"
echo "  停止:      docker compose -f docker-compose.yml -f docker-compose.cuda.yml down"
echo "  验证GPU:   docker exec -it temple-desktop nvidia-smi"
echo "=========================================="
