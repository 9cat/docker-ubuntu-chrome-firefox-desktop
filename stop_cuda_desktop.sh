#!/bin/bash
# ============================================
# CUDA Desktop 停止/清理脚本
# ============================================
# 用法:
#   ./stop_cuda_desktop.sh          停止容器（保留数据）
#   ./stop_cuda_desktop.sh clean    停止容器 + 删除数据
#   ./stop_cuda_desktop.sh purge    停止容器 + 删除数据 + 删除镜像
# ============================================

set -e

COMPOSE="docker compose -f docker-compose.yml -f docker-compose.cuda.yml"

case "${1}" in
  clean)
    echo "⏹️  停止容器..."
    $COMPOSE down -v --remove-orphans
    echo "🗑️  清理数据目录 ./docker-data/ ..."
    rm -rf ./docker-data
    echo "✅ 容器已停止，数据已清理"
    ;;
  purge)
    echo "⏹️  停止容器..."
    $COMPOSE down -v --remove-orphans --rmi all
    echo "🗑️  清理数据目录 ./docker-data/ ..."
    rm -rf ./docker-data
    echo "✅ 容器已停止，数据和镜像已全部清理"
    ;;
  *)
    echo "⏹️  停止容器（数据保留在 ./docker-data/）..."
    $COMPOSE down
    echo "✅ 容器已停止，数据已保留"
    echo ""
    echo "💡 如需同时清理数据:  ./stop_cuda_desktop.sh clean"
    echo "💡 如需彻底清理:      ./stop_cuda_desktop.sh purge"
    ;;
esac
