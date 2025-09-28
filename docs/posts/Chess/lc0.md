# Lc0(Leela Chess Zero)

[仓库地址](https://github.com/LeelaChessZero/lc0/)

[部署参考](https://github.com/LeelaChessZero/lc0/blob/master/README.md#building-and-running-lc0)

## Deployment

Lc0 Linux部署，似乎只能从源码编译/使用Docker。Docker构建可参考：https://github.com/vochicong/lc0-docker。

下面是源码编译的步骤：

```bash
git clone -b release/0.31 --recurse-submodules https://github.com/LeelaChessZero/lc0.git
# Install Backend
# 我的配置：Intel Core i5-6200U CPU 和 Intel HD Graphics 520 集成显卡
# 需要安装OpenBLAS, ninja build (ninja-build), meson, and (optionally) gtest (libgtest-dev).
sudo apt update
sudo apt install libopenblas-dev ninja-build meson libgtest-dev
# 构建lc0
cd lc0
bash ./build.sh  lc0 binary will be in lc0/build/release/ directory
# 手动下载Neural Network weights，也放到lc0/build/release/目录下: https://lczero.org/play/networks/bestnets/
```