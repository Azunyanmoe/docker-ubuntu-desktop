# Ubuntu Desktop

基于 Ubuntu 24.04 的 Xfce4 桌面 Docker 镜像，预装 SDR 相关软件，支持三种远程桌面。

## 功能特性

- 桌面环境：Xfce4
- 远程桌面：NoMachine、KasmVNC、TurboVNC/noVNC
- SDR 软件：SatDump、WSJT-X、JTDX、SDR++、SDRangel、GQRX、CubicSDR、Gpredict、WFView
- 硬件支持：SDRplay RSP API、SoapySDRPlay3
- 编译优化：并行构建 + ccache 加速
- 可选 CUDA 基础镜像

## 远程桌面

| 模式 | 端口 | 环境变量 |
|---|---|---|
| NoMachine（默认） | 4000 | REMOTE_DESKTOP=nomachine |
| KasmVNC | 4000 | REMOTE_DESKTOP=kasmvnc |
| noVNC | 6080 | REMOTE_DESKTOP=novnc |

## 快速开始

```bash
docker run -d --rm \
  --shm-size=2g \
  -p 4000:4000 \
  ghcr.io/azunyanmoe/docker-ubuntu-desktop:latest
```

使用 NoMachine 客户端连接 localhost:4000 访问桌面。

## 环境变量

| 变量 | 默认值 | 说明 |
|---|---|---|
| REMOTE_DESKTOP | nomachine | 远程桌面类型 |
| PASSWORD | 123456 | 用户密码 |
| USER | user | 用户名 |
| UID/GID | 1000 | 用户/组 ID |

## 本地构建

```bash
bash build.sh 24.04
bash build.sh 24.04 12.8.0-cudnn-devel
```

## GitHub Actions

仅 workflow_dispatch 手动触发，构建后推送到 ghcr.io。
