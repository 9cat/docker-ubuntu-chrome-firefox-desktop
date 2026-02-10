#!/bin/bash
# ============================================
# Desktop 启动/停止脚本
# ============================================
# 用法:
#   ./start.sh           启动
#   ./start.sh down      停止
#   ./start.sh restart   重启
#   ./start.sh logs      查看日志
# ============================================

set -e

COMPOSE="docker compose"
CONTAINER_NAME="temple-desktop"

# 检查容器是否已存在
container_exists() {
    docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"
}

# 启动
start_desktop() {
    if container_exists; then
        echo "⚠️  容器 '${CONTAINER_NAME}' 已存在"
        echo ""
        docker ps -f name=${CONTAINER_NAME} --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        read -p "是否先停止并删除现有容器? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "停止现有容器..."
            $COMPOSE down
        else
            echo "取消启动"
            exit 0
        fi
    fi

    echo "========================================"
    echo "Desktop 启动中..."
    echo "========================================"
    mkdir -p ./docker-data/home ./docker-data/docker
    $COMPOSE up -d --build

    echo ""
    echo "========================================"
    echo "Desktop 启动成功！"
    echo "========================================"
    echo "SSH:     ssh temple@localhost -p 10022"
    echo "Web:     https://localhost:16901"
    echo "User:    temple"
    echo "Password: temple"
    echo ""
    echo "⚠️  SECURITY: Change default passwords!"
    echo "   VNC:     docker exec -it temple-desktop sh -c 'echo -e \"新密码\\n新密码\" | vncpasswd'"
    echo "   System:  docker exec -it temple-desktop sh -c 'echo temple:新密码 | chpasswd'"
    echo ""
    echo "Claude Code: SSH login auto-attaches to tmux 'dev' session"
    echo "  Window 0: claude - Claude Code running"
    echo "  Window 1: shell  - General shell"
    echo "========================================"
}

# 停止
stop_desktop() {
    if container_exists; then
        echo "停止容器..."
        $COMPOSE down
        echo "✅ 容器已停止（数据保留在 ./docker-data/）"
    else
        echo "容器未运行"
    fi
}

# 重启
restart_desktop() {
    stop_desktop
    echo ""
    start_desktop
}

# 查看日志
show_logs() {
    $COMPOSE logs -f
}

# 主逻辑
case "${1:-}" in
  down|stop)
    stop_desktop
    ;;
  restart)
    restart_desktop
    ;;
  logs)
    show_logs
    ;;
  *)
    start_desktop
    ;;
esac
