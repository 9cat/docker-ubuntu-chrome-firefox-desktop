# Ubuntu Desktop Development Environment

极简的 Ubuntu 桌面开发环境，包含 Chrome + Firefox + KasmVNC。

## 快速开始

```bash
git clone <your-repo-url>
cd <repo-dir>
./start.sh
```

## 访问

- **Web**: https://localhost:16901
- **SSH**: ssh ubuntu@localhost -p 10022
- **密码**: ubuntu

## 组件

- Ubuntu 24.04
- xfce4 桌面
- KasmVNC (Web 访问)
- Chrome 浏览器
- Firefox 浏览器

## 管理命令

```bash
./start.sh      # 启动
docker-compose down    # 停止
docker-compose logs -f # 查看日志
docker exec -it ubuntu-desktop bash  # 进入容器
```

## 作者

temple <temple@iobond.com>
