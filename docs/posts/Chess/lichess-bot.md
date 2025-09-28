# Lichess

Lichess.org 是一个完全开源、免费、无广告的在线国际象棋服务器。其后端 Lila 使用 Scala 3、Play Framework、Akka Streams 构建，依赖 MongoDB 存储海量棋局，使用 Elasticsearch 进行搜索，并与部署在独立服务器集群上的 Stockfish 引擎交互。

Lichess 是一个复杂的分布式系统。在单台（尤其是资源有限的）校园服务器上完整部署 Lichess 是不现实的。对于资源有限的服务器，将 Stockfish 或 Lc0 设置为网络引擎服务，然后在本地使用 ChessX 或 Scid 等 GUI 连接进行分析，是最为可行且资源友好的方案。

## Lichess Bot

- [官方仓库](https://github.com/lichess-bot-devs/lichess-bot)
- Stockfish，Leela Chess Zero均支持
- [主要参考文档](https://github.com/lichess-bot-devs/lichess-bot/wiki/Setup-the-engine)

### 准备工作

#### 环境配置

```bash
# Development
pip install -r requirements.txt

# Deployment: https://github.com/lichess-bot-devs/lichess-bot/wiki/How-to-use-the-Docker-image
docker pull lichessbotdevs/lichess-bot  大概1G

docker run -d -v /root/lichess-bot:/lichess-bot/config --name myBot --log-driver=json-file --log-opt max-size=10m --log-opt max-file=3 lichessbotdevs/lichess-bot
```

上面这条命令解读：

- `-v /root/lichess-bot:/lichess-bot/config`：将`/root/lichess-bot`挂载到容器的`/lichess-bot/config`

!!!warning
    可能发生“配置文件路径错误 -> 引擎意外终止 -> 容器刚启动就停止”，请仔细阅读配置文件里`engine`下的`dir`路径。

- `--log-driver=json-file --log-opt max-size=10m --log-opt max-file=3`：限制日志文件大小，避免日志无限制增长占满磁盘空间。

!!!note
    日志驱动程序选项`--log-driver`和`--log-opt`必须在镜像名称`lichessbotdevs/lichess-bot`之前指定，即由`docker run`命令本身解析，而不是传递给**容器内部**作为执行命令的一部分。

#### [创建bot](https://lichess.org/api#tag/Bot/operation/botAccountUpgrade)

1. Lichess官网创建新账户，然后**一盘对局也不要下**！！
2. 从Lichess设置获取API Key。
3. 执行命令：`curl -d '' https://lichess.org/api/bot/account/upgrade -H "Authorization: Bearer <yourTokenHere>"`，预期返回`{"ok":true}`。
4. 登录账户检查是否已有`bot`头衔。

#### 引擎准备

最好选择在部署机器上编译的引擎，或者是官网的通用版本，以避免因系统库版本不兼容导致引擎无法启动的问题。注意：**上传文件后需要加权限**。

!!!note
    我用XFTP传的引擎文件，是用Ubuntu24.04编译的`stockfish`可执行文件，加权限后仍然报错：`chess.engine.EngineTerminatedError: engine process died unexpectedly (exit code: 1)`。开始时猜测是缺少`.nnue`文件，结果补传上去之后还报同样错。最终找到问题：服务器是Ubuntu22.04，不兼容我在WSL上手动编译的`stockfish`版本。在官网下载对应的x64通用版本后成功解决问题。

### 项目配置

配置文件编写参考[config.yml](./config.yml)。自定义配置参考：[Extra-customizations](https://github.com/lichess-bot-devs/lichess-bot/wiki/Extra-customizations)。

项目内(容器外)需要自己准备的文件：

- `engines/<engine_name>`：引擎文件
- `engines/books/book1.bin`：预定义开局库，可参考[stockfish-books](https://github.com/official-stockfish/books)
- `engines/syzygy/3-4-5-syzygy`：残局库，可参考[syzygy1/tb](https://github.com/syzygy1/tb)
