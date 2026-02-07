# Android Emulator & Waydroid 支持

本分支添加了两种 Android 运行方案，均支持在 Docker 沙箱中运行。

## 系统要求

| 资源 | 最低要求 | 推荐配置 |
|------|----------|----------|
| 内存 | 4 GB | 8 GB+ |
| CPU | 2 核 | 4 核+ |
| 磁盘 | 20 GB | 50 GB+ |
| 宿主机 | KVM 支持 | Intel VT-x / AMD-V |

## 宿主机准备

```bash
# 确保 KVM 模块已加载
sudo modprobe kvm
sudo modprobe kvm_intel   # Intel CPU
# 或
sudo modprobe kvm_amd     # AMD CPU

# 检查 KVM
ls -la /dev/kvm

# 确保当前用户在 kvm 组
sudo usermod -aG kvm $USER
```

## 方案一：Android Emulator (推荐)

### 启动模拟器

```bash
# 在容器桌面中，打开终端运行：
android-emulator

# 或带参数运行：
android-emulator -no-boot-anim -memory 4096
```

### ADB 连接

```bash
# 模拟器启动后，ADB 自动连接
adb devices

# 安装 APK
adb install your-app.apk
```

### Python 自动化 (uiautomator2)

```python
import uiautomator2 as u2

# 连接模拟器
d = u2.connect()  # 自动连接

# 获取设备信息
print(d.info)

# 点击坐标
d.click(500, 1000)

# 点击元素
d(text="Settings").click()

# 输入文本
d(resourceId="com.example:id/input").set_text("Hello")

# 截图
d.screenshot("screen.png")

# 获取所有元素
xml = d.dump_hierarchy()

# 启动 APP
d.app_start("com.example.app")

# 滑动
d.swipe(500, 1500, 500, 500)
```

### Web UI 调试 (weditor)

```bash
# 启动可视化调试工具
python3 -m weditor

# 在浏览器打开 http://localhost:17310
```

## 方案二：Waydroid

> 注意：Waydroid 在 Docker 中支持有限，可能需要额外配置

### 首次初始化

```bash
# 初始化 Waydroid (下载系统镜像)
sudo waydroid init

# 启动 Waydroid (在 Weston 中)
waydroid-start
```

### 安装 APK

```bash
waydroid app install your-app.apk
```

## 两种方案对比

| 特性 | Android Emulator | Waydroid |
|------|------------------|----------|
| 性能 | 中等 (KVM加速) | 高 (原生容器) |
| 兼容性 | 极佳 | 一般 |
| ADB 支持 | 完整 | 有限 |
| 自动化工具 | 完整 (uiautomator2) | 有限 |
| Docker 支持 | 好 | 复杂 |
| Play Store | 可选 | 可安装 |

## 自动化 API 示例

### 模拟点击

```python
import uiautomator2 as u2
d = u2.connect()

# 方式1: 坐标点击
d.click(100, 200)

# 方式2: 元素点击
d(text="登录").click()
d(resourceId="com.app:id/btn").click()
d(className="android.widget.Button").click()
```

### 获取数据

```python
# 获取屏幕文本
texts = d(className="android.widget.TextView").get_text()

# 获取元素属性
info = d(resourceId="com.app:id/title").info

# 导出 UI 层次结构
hierarchy = d.dump_hierarchy()
```

### 手势操作

```python
# 滑动
d.swipe(500, 1500, 500, 500, duration=0.5)

# 长按
d.long_click(500, 500)

# 双击
d.double_click(500, 500)

# 拖拽
d.drag(100, 100, 500, 500)
```

## 故障排除

### KVM 权限问题

```bash
# 检查 KVM 设备
ls -la /dev/kvm

# 如果权限不足，在宿主机运行：
sudo chmod 666 /dev/kvm
```

### 模拟器启动失败

```bash
# 使用软件渲染 (慢但兼容性好)
android-emulator -gpu swiftshader_indirect

# 查看日志
adb logcat
```

### Waydroid 初始化失败

```bash
# 手动下载系统镜像
sudo waydroid init -s GAPPS -f
```
