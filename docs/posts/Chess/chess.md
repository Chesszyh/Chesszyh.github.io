# Chess

## Chess AI

- [Train Your Own Chess AI](https://medium.com/data-science/train-your-own-chess-ai-66b9ca8d71e4)
  - [Medium Code图片导出美化](https://carbon.now.sh/)
  - [文章提到的一个GPU平台](https://lightning.ai/)
- [fishtest](https://tests.stockfishchess.org/)

## Lichess

### Lichess Server

Lichess.org 是一个完全开源、免费、无广告的在线国际象棋服务器。其后端 Lila 使用 Scala 3、Play Framework、Akka Streams 构建，依赖 MongoDB 存储海量棋局，使用 Elasticsearch 进行搜索，并与部署在独立服务器集群上的 Stockfish 引擎交互。

Lichess 是一个复杂的分布式系统。在单台（尤其是资源有限的）校园服务器上完整部署 Lichess 是不现实的。对于资源有限的服务器，将 Stockfish 或 Lc0 设置为网络引擎服务，然后在本地使用 ChessX 或 Scid 等 GUI 连接进行分析，是最为可行且资源友好的方案。

### Lichess Bot

- [官方仓库](https://github.com/lichess-bot-devs/lichess-bot)
- Stockfish，Leela Chess Zero均支持
- [主要参考文档](https://github.com/lichess-bot-devs/lichess-bot/wiki/Setup-the-engine)

#### 准备工作

先克隆仓库、拉取镜像、创建bot账户。然后配置环境：

```bash
git clone https://github.com/lichess-bot-devs/lichess-bot
# Docker方式安装参考：https://github.com/lichess-bot-devs/lichess-bot/wiki/How-to-use-the-Docker-image。
docker pull lichessbotdevs/lichess-bot # 大概1G
# 或使用Ubuntu+Python 3.9+安装(便于调试)
sudo apt install python3 python3-pip python3-virtualenv python3-venv
python3 -m venv venv # If this fails you probably need to add Python3 to your PATH.
virtualenv venv -p python3
source ./venv/bin/activate
python3 -m pip install -r requirements.txt
```

- **创建bot**：参考https://lichess.org/api#tag/Bot/operation/botAccountUpgrade。

1. Lichess官网创建新账户，然后**一盘对局也不要下**！！
2. 从Lichess设置获取API Key。
3. 执行命令：`curl -d '' https://lichess.org/api/bot/account/upgrade -H "Authorization: Bearer <yourTokenHere>"`，预期返回`{"ok":true}`。
4. 登录账户检查是否已有`bot`头衔。

#### 项目配置: Stockfish Bot

配置文件`config.yml`解读参考：[Summary by AI](./lichess-bot-setting.md)。项目内(容器外)需要自己准备的文件：

- `engines/<engine_name>`：引擎文件，并且注意要改配置。比如：

```yaml
engine:                            # Engine settings.
  dir: "/lichess-bot/config/engines/stockfish"        # Directory containing the engine. This can be an absolute path or one relative to lichess-bot/.
  name: "stockfish-ubuntu-x86-64-avx2"                # Binary name of the engine to use.
```

- `engines/book.bin`：预定义开局库，可以使用`polyglot`格式。
- `engines/syzygy`：残局库，参考https://github.com/syzygy1/tb

---

配置文件编写参考[config.yml](./config.yml)。

TODO: https://github.com/lichess-bot-devs/lichess-bot/wiki/Extra-customizations 和残局库：3-4-5_pieces_Syzygy.zip

> 踩坑：配置文件路径找不到+引擎意外终止，导致容器刚启动就停止。

原因分析：

1. 文件路径找不到，可能是相对路径的锅。配置文件`engine`下键值原本是`"dir: ./engines"`。根据启动命令`docker run -d -v /root/lichess-bot:/lichess-bot/config --name myBot lichessbotdevs/lichess-bot`或`docker run -d -v /home/chesszyh/Develop/Chess/lichess-bot:/lichess-bot/config --name myBot lichessbotdevs/lichess-bot`，这是将`/root/lichess-bot`挂载到容器的`/lichess-bot/config`。所以将配置文件路径改为**绝对路径**`"dir: /lichess-bot/config/engines"`即可。

或者在启动时限制日志文件大小：`docker run -d -v /root/lichess-bot:/lichess-bot/config --name myBot --log-driver=json-file --log-opt max-size=10m --log-opt max-file=3 lichessbotdevs/lichess-bot`。注意日志驱动程序选项`--log-driver`和`--log-opt`必须在镜像名称`lichessbotdevs/lichess-bot`之前指定，即由`docker run`命令本身解析，而不是传递给**容器内部**作为执行命令的一部分。

2. 我用XFTP传的引擎文件，是用Ubuntu24.04编译的`stockfish`可执行文件，注意**上传文件后需要加权限**，仍然报错：`chess.engine.EngineTerminatedError: engine process died unexpectedly (exit code: 1)`。开始时猜测是缺少`.nnue`文件，结果补传上去之后还报同样错。最终找到问题：服务器是Ubuntu22.04，不兼容我在WSL上手动编译的`stockfish`版本。在官网下载对应的x64通用版本后成功解决问题。

运行截图： ![alt text](bot启动.png)

正常对弈(下不过)： ![alt text](bot对弈.png)

> 新的问题：这个bot把我的云服务器炸了，应该也是内存耗尽了……
> 之前的防OOM机制失败了吗？我现在又连SSH也上不去了……

#### Lc0(Leela Chess Zero) Bot

[仓库地址](https://github.com/LeelaChessZero/lc0/)

[部署参考](https://github.com/LeelaChessZero/lc0/blob/master/README.md#building-and-running-lc0)

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
bash ./build.sh # lc0 binary will be in lc0/build/release/ directory
# 手动下载Neural Network weights，也放到lc0/build/release/目录下
# https://lczero.org/play/networks/bestnets/
```