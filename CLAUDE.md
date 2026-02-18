# docker-ubuntu-chrome-firefox-desktop

## 项目概述
这是一个基于Docker的Ubuntu桌面开发环境，提供了完整的桌面体验、浏览器、开发工具和可选的NVIDIA GPU加速支持。

## 主要功能
- **Ubuntu 24.04** 基础镜像
- **XFCE4** 轻量级桌面环境
- **KasmVNC** 基于Web的远程桌面（HTTPS）
- **Chrome + Firefox ESR** 浏览器
- **Claude Code** - Anthropic的AI编程助手（自动在tmux中启动）
- **Docker-in-Docker** - 容器内隔离的Docker守护进程
- **中文支持** - 字体和输入法（拼音 + 五笔）
- **SSH密钥认证** - 安全访问
- **NVIDIA CUDA Toolkit** - 深度学习、GPU计算（可选）
- **OpenGL/EGL/Vulkan** - 通过VirtualGL的硬件加速3D渲染

## 快速开始

### 标准版本（无GPU）
```bash
git clone https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop.git
cd docker-ubuntu-chrome-firefox-desktop
docker compose up -d --build
```

或使用快速启动脚本：
```bash
./quickstart.sh
```

### CUDA/GPU支持版本
```bash
./start_cuda_desktop.sh
```

## 访问方式

| 服务 | URL | 凭据 |
|---------|-----|-------------|
| Web桌面 | https://localhost:16901 | temple / temple |
| SSH | `ssh temple@localhost -p 10022` | SSH密钥 |

## 数据存储

数据存储在 `./docker-data/`（绑定挂载），**不在** `/var/lib/docker/volumes/`：

```
./docker-data/
├── home/     用户数据 (/home/temple)
└── docker/   Docker-in-Docker数据
```

## 环境变量

| 变量 | 默认值 | 描述 |
|----------|---------|-------------|
| `PASSWORD` | temple | Linux用户密码 |
| `VNC_PASSWORD` | temple | VNC登录密码 |
| `TZ` | Asia/Shanghai | 时区 |
| `SSH_PUBLIC_KEY` | （内置密钥） | 自定义SSH公钥 |
| `NVIDIA_VISIBLE_DEVICES` | all | GPU可见性（仅CUDA） |
| `NVIDIA_DRIVER_CAPABILITIES` | all | GPU能力（仅CUDA） |

## 管理命令

```bash
# 标准版本
docker compose up -d --build          # 启动
docker compose down                   # 停止（保留数据）
./stop_desktop.sh                     # 停止
./stop_desktop.sh clean               # 停止 + 删除数据
./stop_desktop.sh purge               # 停止 + 删除数据 + 删除镜像

# CUDA版本
docker compose -f docker-compose.yml -f docker-compose.cuda.yml up -d
./stop_cuda_desktop.sh [clean|purge]

# 日志
docker compose logs -f

# 验证GPU
docker exec -it temple-desktop nvidia-smi
docker exec -it temple-desktop nvcc --version
```

## CUDA详情

### 支持的版本

| Ubuntu | CUDA版本 |
|--------|---------------|
| 24.04 | 12.6.2, 12.5.1, 12.4.1, 12.3.2 |

### 驱动兼容性

| CUDA | 最低驱动版本 |
|------|----------------|
| 12.6 | 560.28+ |
| 12.4 | 550.54+ |
| 12.2 | 535.86+ |
| 11.8 | 520.61+ |

## 分支

| 分支 | 描述 | 链接 |
|--------|-------------|------|
| `main` | 完整桌面 + CUDA支持（此分支） | [main](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop) |
| `cuda-support` | CUDA开发分支 | [cuda-support](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop/tree/cuda-support) |
| `android-support` | Android模拟器 + 自动化 | [android-support](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop/tree/android-support) |

## 项目结构

```
.
├── Dockerfile                      # 主Dockerfile
├── docker-compose.yml             # Docker Compose配置（标准版本）
├── docker-compose.cuda.yml        # Docker Compose配置（CUDA版本）
├── entrypoint.sh                  # 容器入口脚本
├── start.sh                       # 启动脚本
├── start_cuda_desktop.sh          # CUDA版本一键启动脚本
├── stop_desktop.sh                # 停止脚本（标准版本）
├── stop_cuda_desktop.sh           # 停止脚本（CUDA版本）
├── quickstart.sh                  # 快速启动脚本
├── build-cuda.sh                  # CUDA构建脚本
├── README.md                      # 英文文档
├── README_zh.md                   # 中文文档
├── CUDA.md                        # CUDA文档
├── LICENSE                        # MIT许可证
└── .env                           # 环境变量配置
```

## 许可证

MIT

## 作者

temple <temple@iobond.com>
