# CUDA & OpenGL GPU 加速支持

本分支添加了 NVIDIA CUDA 和 OpenGL 硬件加速支持。

## 特性

- **CUDA 支持**: 基于 `nvidia/cuda` 官方镜像，自动兼容新驱动
- **OpenGL 硬件加速**: 通过 VirtualGL 实现 3D 渲染加速
- **Vulkan 支持**: GPU 加速的图形 API
- **灵活版本**: 可选择不同 CUDA 版本

## 宿主机要求

### 1. 安装 NVIDIA 驱动

```bash
# Ubuntu
sudo apt-get update
sudo apt-get install -y nvidia-driver-550  # 或最新版本

# 验证
nvidia-smi
```

### 2. 安装 NVIDIA Container Toolkit

```bash
# 添加仓库
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
    sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# 安装
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# 配置 Docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# 验证
docker run --rm --gpus all nvidia/cuda:12.6.2-base-ubuntu24.04 nvidia-smi
```

## 构建镜像

### 方式一：使用构建脚本

```bash
# 默认 CUDA 12.6.2
./build-cuda.sh

# 指定 CUDA 版本
./build-cuda.sh 12.4.1
./build-cuda.sh 11.8.0
```

### 方式二：使用 Docker Compose

```bash
docker compose -f docker-compose.yml -f docker-compose.cuda.yml build
```

### 方式三：手动构建

```bash
docker build \
    --build-arg BASE_IMAGE=nvidia/cuda:12.6.2-devel-ubuntu24.04 \
    -t temple-desktop:cuda .
```

## 运行容器

### 使用 Docker Compose (推荐)

```bash
docker compose -f docker-compose.yml -f docker-compose.cuda.yml up -d
```

### 手动运行

```bash
docker run -d \
    --name temple-desktop-cuda \
    --gpus all \
    --shm-size=2gb \
    -p 16901:6901 \
    -p 10022:22 \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    temple-desktop:cuda
```

## 支持的 CUDA 版本

基于 `nvidia/cuda` 官方镜像，支持以下版本：

| Ubuntu 版本 | CUDA 版本 |
|-------------|-----------|
| 24.04 | 12.6.2, 12.5.1, 12.4.1, 12.3.2 |
| 22.04 | 12.6.2, 12.5.1, 12.4.1, 11.8.0, 11.7.1 |
| 20.04 | 11.8.0, 11.7.1, 11.6.2, 11.4.3 |

完整列表: https://hub.docker.com/r/nvidia/cuda/tags

## 驱动兼容性

CUDA 版本与 NVIDIA 驱动的兼容关系：

| CUDA 版本 | 最低驱动版本 |
|-----------|-------------|
| 12.6 | 560.28+ |
| 12.4 | 550.54+ |
| 12.2 | 535.86+ |
| 12.0 | 525.60+ |
| 11.8 | 520.61+ |
| 11.7 | 515.43+ |

**重要**: 使用 `nvidia/cuda` 作为基础镜像的优势是 NVIDIA 官方维护，确保与新驱动兼容。

## 验证 GPU 加速

### 检查 CUDA

```bash
# 在容器内运行
nvidia-smi
nvcc --version
```

### 检查 OpenGL

```bash
# 软件渲染 (默认)
glxinfo | grep "OpenGL renderer"

# 硬件加速 (使用 vglrun)
vglrun glxinfo | grep "OpenGL renderer"
# 应显示 NVIDIA GPU 型号
```

### 检查 Vulkan

```bash
vulkaninfo | grep -i "GPU"
vkcube  # 运行 Vulkan demo
```

### 运行 3D 应用

```bash
# 使用 vglrun 启用硬件加速
vglrun glxgears
vglrun blender
```

## 环境变量

容器内已设置以下环境变量：

```bash
export NVIDIA_VISIBLE_DEVICES=all
export NVIDIA_DRIVER_CAPABILITIES=all
export VGL_DISPLAY=egl

# CUDA (如果使用 CUDA 镜像)
export CUDA_HOME=/usr/local/cuda
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
```

## 常见问题

### GPU 不可用

```bash
# 检查宿主机驱动
nvidia-smi

# 检查 nvidia-container-toolkit
docker run --rm --gpus all nvidia/cuda:12.6.2-base-ubuntu24.04 nvidia-smi
```

### OpenGL 渲染慢

确保使用 `vglrun` 前缀运行 3D 应用：
```bash
vglrun your-3d-app
```

### CUDA 版本不兼容

更新宿主机 NVIDIA 驱动，或使用较低版本的 CUDA 基础镜像。

## 与 Android 分支配合

如需同时支持 CUDA 和 Android 模拟器，可以合并两个分支的修改：

```bash
git checkout cuda-support
git merge android-support
```
