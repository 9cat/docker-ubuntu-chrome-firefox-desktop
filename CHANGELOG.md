# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-01

### Added
- Ubuntu 24.04 Desktop environment with XFCE4
- KasmVNC for web-based remote desktop (HTTPS)
- Google Chrome and Firefox ESR browsers
- Claude Code (AI coding assistant) - auto-starts in tmux
- Docker-in-Docker (DinD) with isolated daemon
- Chinese language support (fonts + fcitx5 input method)
- SSH key-based authentication
- Persistent user data volume (`./docker-data/home`)
- Persistent Docker data volume (`./docker-data/docker`)
- Project documentation (README.md, README_zh.md, CUDA.md)

### Changed
- Fixed Claude Code installation to use dynamic version detection instead of hardcoded version
- Modified port range from 51200-51239 to 51100-51129 to avoid conflicts
- Ensured `/usr/local/bin` is first in PATH for Claude Code accessibility

### Fixed
- Claude Code not found after SSH login due to:
  - Hardcoded version number in symlink (2.1.47 vs actual 2.1.63)
  - PATH configuration issues with volume mount overrides
- Volume mount configuration now uses relative paths (`./docker-data/`)
- DNS resolution issues with explicit DNS servers in docker-compose.yml

[1.0.0]: https://github.com/9cat/docker-ubuntu-chrome-firefox-desktop/releases/tag/v1.0.0
