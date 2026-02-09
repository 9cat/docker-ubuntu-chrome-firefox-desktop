# Ubuntu 桌面开发环境

[![Docker Hub](https://img.shields.io/docker/pulls/canadianbitcoin/dev-desktop)](https://hub.docker.com/r/canadianbitcoin/dev-desktop)

极简 Ubuntu 桌面环境，集成 Chrome、Firefox、Claude Code 和 KasmVNC 远程桌面。

[English](README.md)

## 功能特性

- **Ubuntu 24.04** 基础镜像
- **XFCE4** 轻量级桌面环境
- **KasmVNC** 网页远程桌面（HTTPS）
- **Chrome** + **Firefox ESR** 浏览器（Chrome 为默认）
- **Claude Code** - Anthropic AI 编程助手，自动启动
- **tmux 会话** - 预配置的开发会话
- **Docker-in-Docker** - 容器内创建和管理容器
- **中文支持** - 字体和输入法（拼音 + 五笔）
- **自动信任的 SSL 证书** - 无浏览器警告
- **SSH 公钥认证** - 安全访问

## 快速开始

### 方式一：使用预构建镜像（推荐）

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
      - ./docker-data/home:/home/temple
      - ./docker-data/docker:/var/lib/docker
    shm_size: 2gb
EOF

docker compose up -d
```

### 方式二：从源码构建

```bash
git clone https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop.git
cd docker-ubuntu-chrome-firefox-desktop
docker compose up -d --build
```

## 访问方式

| 服务 | 地址 | 凭证 |
|------|------|------|
| 网页桌面 | https://localhost:16901 | temple / temple |
| SSH | `ssh temple@localhost -p 10022` | 仅 SSH 密钥 |

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `PASSWORD` | temple | VNC 网页密码 |
| `VNC_PASSWORD` | temple | VNC 登录密码 |
| `TZ` | Asia/Shanghai | 时区 |
| `SSH_PUBLIC_KEY` | (内置) | SSH 公钥认证 |

### SSH 配置

SSH 仅支持**公钥认证**。使用自定义密钥：

```yaml
environment:
  - SSH_PUBLIC_KEY=ssh-rsa AAAA... 你的密钥备注
```

或挂载 authorized_keys 文件：

```yaml
volumes:
  - ./authorized_keys:/home/temple/.ssh/authorized_keys:ro
```

## Claude Code

容器启动时，Claude Code 会在 tmux 会话中自动启动。

```bash
# SSH 登录容器
ssh temple@localhost -p 10022

# 连接 tmux 会话（Claude Code 已在运行）
tmux attach -t dev
```

### tmux 窗口

| 窗口 | 名称 | 用途 |
|------|------|------|
| 0 | claude | Claude Code（自动启动）|
| 1 | shell | 通用终端 |

### tmux 快捷键

| 快捷键 | 操作 |
|--------|------|
| `Ctrl+b d` | 分离会话 |
| `Ctrl+b n` | 下一窗口 |
| `Ctrl+b p` | 上一窗口 |

### API 密钥

设置 Anthropic API 密钥：

```bash
echo 'export ANTHROPIC_API_KEY=你的密钥' >> ~/.bashrc
```

## 中文输入

已预装中文字体和输入法（fcitx5）：

- **拼音**
- **五笔**

| 快捷键 | 操作 |
|--------|------|
| `Ctrl+Space` | 切换中英文 |
| `Ctrl+Shift` | 切换拼音/五笔 |

## Docker-in-Docker

默认启用真正的 Docker-in-Docker。容器内运行独立的 Docker 守护进程：

```bash
docker ps              # 列出容器（容器内部）
docker run hello-world # 运行容器（与宿主机隔离）
```

容器内创建的容器完全与宿主机隔离。端口 51200-51239 已映射供内部容器服务使用。

如需切换到 Docker-outside-of-Docker（共享宿主机 Docker），编辑 `docker-compose.yml`：
```yaml
privileged: false
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

## 管理命令

```bash
docker compose up -d          # 启动
docker compose down           # 停止（保留数据）
docker compose logs -f        # 查看日志
docker compose up -d --build  # 重新构建
./stop_desktop.sh             # 停止容器
./stop_desktop.sh clean       # 停止 + 删除数据
./stop_desktop.sh purge       # 停止 + 删除数据 + 删除镜像
```

## 数据存储

数据存储在项目目录下的 `./docker-data/`（bind mount），不使用 Docker named volumes：

```
./docker-data/
├── home/     用户数据 (/home/temple)
└── docker/   Docker-in-Docker 数据
```

如需修改存储位置，编辑 `docker-compose.yml` 中的 volumes 路径。

## 端口

| 端口 | 服务 |
|------|------|
| 22 | SSH |
| 6901 | KasmVNC (HTTPS) |

## 许可证

MIT

## 作者

temple <temple@iobond.com>
