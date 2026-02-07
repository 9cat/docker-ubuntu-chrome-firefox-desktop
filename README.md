# Ubuntu Desktop Development Environment

[![Docker Hub](https://img.shields.io/docker/pulls/canadianbitcoin/temple-desktop-dev)](https://hub.docker.com/r/canadianbitcoin/temple-desktop-dev)
[![GitHub](https://img.shields.io/badge/GitHub-9cat%2Fdocker--ubuntu--chrome--firefox--desktop-blue)](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop)

Minimal Ubuntu Desktop environment with Chrome, Firefox, Claude Code, KasmVNC, and **Android Emulator with automation tools** for app testing and development.

[中文文档](README_zh.md) | [Android 详细文档](ANDROID.md)

---

## Branch: `android-support`

This branch adds **Android Emulator and automation tools** for running and automating Android apps in a Docker sandbox.

### Release Notes

| Version | Date | Changes |
|---------|------|---------|
| android-support | 2025-02-08 | Initial Android Emulator + Waydroid support |

### What's New in This Branch

- **Android Emulator**: Android SDK 34 with Pixel 6 AVD, KVM hardware acceleration
- **Waydroid**: Container-based Android (alternative option)
- **Python Automation**: uiautomator2, adbutils for app automation
- **ADB + scrcpy**: Android debugging and screen control
- **Desktop Shortcuts**: Easy launcher for Android Emulator

### Links

| Resource | URL |
|----------|-----|
| This Branch | https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop/tree/android-support |
| Main Branch | https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop |
| CUDA Branch | https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop/tree/cuda-support |
| Docker Hub | https://hub.docker.com/r/canadianbitcoin/temple-desktop-dev |
| Android Documentation | [ANDROID.md](ANDROID.md) |

---

## Features

### Base Features
- **Ubuntu 24.04** base image
- **XFCE4** lightweight desktop environment
- **KasmVNC** web-based remote desktop (HTTPS)
- **Chrome** + **Firefox ESR** browsers
- **Claude Code** - Anthropic's AI coding assistant
- **Docker-in-Docker** - Container management from within
- **Chinese support** - Fonts and input methods (Pinyin + Wubi)

### Android Features (This Branch)
- **Android SDK 34** - Latest Android platform
- **Pixel 6 AVD** - Pre-configured virtual device
- **KVM Acceleration** - Hardware-accelerated emulation
- **uiautomator2** - Python automation for Android
- **ADB** - Android Debug Bridge
- **scrcpy** - Screen mirroring and control
- **Waydroid** - Container-based Android (optional)

---

## Prerequisites (Host Machine)

### KVM Support (Required for Android Emulator)

```bash
# Check KVM support
ls -la /dev/kvm

# Load KVM modules
sudo modprobe kvm
sudo modprobe kvm_intel   # Intel CPU
# or
sudo modprobe kvm_amd     # AMD CPU

# Set permissions
sudo chmod 666 /dev/kvm
# or add user to kvm group
sudo usermod -aG kvm $USER
```

---

## Quick Start

### Option 1: Docker Compose (Recommended)

```bash
git clone https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop.git
cd docker-ubuntu-chrome-firefox-desktop
git checkout android-support

# Build and run
docker compose up -d --build
```

### Option 2: Manual Docker Run

```bash
# Build
docker build -t temple-desktop:android .

# Run with KVM
docker run -d --name temple-desktop-android \
    --privileged \
    --shm-size=2gb \
    --device /dev/kvm:/dev/kvm \
    --group-add kvm \
    -p 16901:6901 \
    -p 10022:22 \
    temple-desktop:android
```

---

## Using Android Emulator

### Start Emulator

```bash
# In container terminal or via SSH
android-emulator

# With options
android-emulator -no-boot-anim -memory 4096
```

### ADB Commands

```bash
# List devices
adb devices

# Install APK
adb install your-app.apk

# Screenshot
adb exec-out screencap -p > screen.png

# Simulate tap
adb shell input tap 500 1000

# Input text
adb shell input text "hello"
```

---

## Python Automation (uiautomator2)

### Basic Usage

```python
import uiautomator2 as u2

# Connect to emulator
d = u2.connect()

# Get device info
print(d.info)

# Click by coordinates
d.click(500, 1000)

# Click by text
d(text="Settings").click()

# Click by resource ID
d(resourceId="com.example:id/button").click()

# Input text
d(resourceId="com.example:id/input").set_text("Hello World")

# Screenshot
d.screenshot("screen.png")

# Start app
d.app_start("com.example.app")

# Get UI hierarchy (for finding elements)
xml = d.dump_hierarchy()
print(xml)
```

### Gestures

```python
# Swipe
d.swipe(500, 1500, 500, 500, duration=0.5)

# Long press
d.long_click(500, 500)

# Double tap
d.double_click(500, 500)

# Drag
d.drag(100, 100, 500, 500)
```

### Web UI Debugger

```bash
# Start weditor (visual UI inspector)
python3 -m weditor

# Open in browser: http://localhost:17310
```

---

## Access

| Service | URL | Credentials |
|---------|-----|-------------|
| Web Desktop | https://localhost:16901 | temple / temple |
| SSH | `ssh temple@localhost -p 10022` | SSH key or password |

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PASSWORD` | temple | Linux user password |
| `VNC_PASSWORD` | temple | VNC login password |
| `TZ` | Asia/Shanghai | Timezone |
| `ANDROID_SDK_ROOT` | /opt/android-sdk | Android SDK path |
| `ANDROID_HOME` | /opt/android-sdk | Android SDK path |

---

## Installed Tools

| Tool | Description | Usage |
|------|-------------|-------|
| `android-emulator` | Launch Android Emulator | `android-emulator` |
| `adb` | Android Debug Bridge | `adb devices` |
| `scrcpy` | Screen mirror/control | `scrcpy` |
| `uiautomator2` | Python automation | `import uiautomator2 as u2` |
| `weditor` | Visual UI debugger | `python3 -m weditor` |
| `waydroid-start` | Launch Waydroid | `waydroid-start` |

---

## Comparison: Android Emulator vs Waydroid

| Feature | Android Emulator | Waydroid |
|---------|------------------|----------|
| Performance | Medium (KVM) | High (container) |
| Compatibility | Excellent | Good |
| ADB Support | Full | Limited |
| Automation (uiautomator2) | Full | Limited |
| Docker Support | Good | Complex |
| Play Store | Optional | Installable |
| Recommended for | Automation, Testing | Daily use |

---

## Other Branches

| Branch | Description | Link |
|--------|-------------|------|
| `main` | Base desktop environment | [main](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop) |
| `cuda-support` | CUDA/OpenGL GPU acceleration | [cuda-support](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop/tree/cuda-support) |
| `android-support` | Android Emulator + automation (this branch) | [android-support](https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop/tree/android-support) |

### Combine Android + CUDA

```bash
git checkout android-support
git merge cuda-support
# Resolve conflicts and build
```

---

## Troubleshooting

### KVM Permission Denied

```bash
# On host machine
sudo chmod 666 /dev/kvm
# or
sudo usermod -aG kvm $USER
```

### Emulator Won't Start

```bash
# Use software rendering (slower but works)
android-emulator -gpu swiftshader_indirect

# Check logs
adb logcat
```

### ADB Not Detecting Emulator

```bash
# Restart ADB server
adb kill-server
adb start-server
adb devices
```

---

## License

MIT

## Author

temple <temple@iobond.com>
