# Ubuntu Desktop Development Environment

极简的 Ubuntu 桌面开发环境，包含 Chrome + Firefox + KasmVNC。

## 快速开始

```bash
git clone https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop.git
cd docker-ubuntu-chrome-firefox-desktop
./start.sh
```

## 访问

- **Web**: http://localhost:13000
- **用户**: abc (LinuxServer 默认用户)
- **密码**: ubuntu

## 组件

- Ubuntu 24.04 (Noble)
- xfce4 桌面
- KasmVNC (Web 访问)
- Chrome 浏览器
- Firefox 浏览器

## 管理命令

```bash
./start.sh      # 启动
docker compose down    # 停止
docker compose logs -f # 查看日志
```

## 作者

temple <temple@iobond.com>

## Sources

- [LinuxServer KasmVNC Base Images](https://github.com/linuxserver/docker-baseimage-kasmvnc)
- [KasmVNC](https://github.com/kasmtech/KasmVNC)
