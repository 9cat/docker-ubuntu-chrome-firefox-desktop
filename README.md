# Ubuntu Desktop Development Environment

极简的 Ubuntu 桌面开发环境，包含 Chrome + Firefox + KasmVNC。

## 快速开始

```bash
git clone https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop.git
cd docker-ubuntu-chrome-firefox-desktop
./start.sh
```

## 访问

- **Web**: http://localhost:16901
- **SSH**: ssh ubuntu@localhost -p 10022
- **用户**: ubuntu
- **密码**: ubuntu

## 组件

- **基础镜像**: Ubuntu 24.04 (官方纯净镜像)
- **桌面**: xfce4
- **远程访问**: KasmVNC
- **浏览器**: Chrome + Firefox

## 管理命令

```bash
./start.sh      # 启动
docker compose down    # 停止
docker compose logs -f # 查看日志
```

## 作者

temple <temple@iobond.com>
