# 工具探索

## Terminal

### Tmux

`tmux` 是一个强大的终端复用器 (terminal multiplexer)，它允许你在单个终端窗口中创建、访问和控制多个终端会话。即使你断开 SSH 连接或关闭了本地终端，`tmux` 中的会话和正在运行的程序也会继续在后台运行。

#### 概念层级

*   **服务器 (Server)**：当你第一次启动 `tmux` 时，它会在后台启动一个服务器进程。所有会话、窗口和窗格都由这个**服务器**管理。
*   **会话 (Session)**：**一个会话是一组窗口的集合**。你可以创建多个会话，并在它们之间切换。会话可以在你断开连接后继续存在。
*   **窗口 (Window)**：一个**窗口**占据整个终端屏幕，可以看作是浏览器中的一个标签页。
*   **窗格 (Pane)**：一个窗口可以被分割成多个独立的**窗格**，每个窗格都是一个独立的伪终端。

#### 常用命令

- `tmux new -s <session_name>`：创建一个新的会话并命名
- `tmux attach`：附加到最近的会话(进入之前的会话)
- `tmux detach`：分离当前会话，返回到普通终端
    - 或者在 `tmux` 环境内使用快捷键 `Ctrl+b` + `d`
- `tmux kill-session -t <session_name>`：杀死指定的会话
    - `tmux kill-server`：杀死所有会话(即杀死“服务器”)

- `ctrl+b`组合键：
    - `c`：创建新窗口
    - `n`：下一个窗口(next)
    - `n(数字)`：切换到第 n 个窗口
    - `p`：上一个窗口(previous)
    - `w`：列出所有窗口(window list)

### Claude Code

https://docs.anthropic.com/zh-CN/docs/claude-code/tutorials#mcp-2

### 终端录制:asciinema vs vhs

最开始搜到的是`terminalizer`，但这个库已经7年以上的历史了，有些太旧了，开发也不是很积极。我使用时最开始用的root用户，报错：`Running as root without --no-sandbox is not supported`，是由 terminalizer 用于渲染的 Electron 进程引起的。当以 root 用户身份运行 Electron 应用时，出于安全原因，需要 --no-sandbox 标志。我尝试加参数，发现terminalizer不太能正确识别参数，就算了。

最近比较活跃的是`asciinema`和`vhs`。对比之下我更喜欢asciinema，比较轻量级、也没那么多依赖问题，**对Headless服务器非常友好**。

#### 安装

```bash
# asciinema: need cargo
cargo install --locked --git https://github.com/asciinema/asciinema

# vhs: 
# Install vsh on Debian/Ubuntu
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
# Install ttyd from https://github.com/tsl0922/ttyd/releases
echo "Installing ttyd..."
sudo apt-get update
sudo apt-get install -y build-essential cmake git libjson-c-dev libwebsockets-dev
git clone https://github.com/tsl0922/ttyd.git
cd ttyd && mkdir build && cd build
cmake ..
make && sudo make install
echo "ttyd installed successfully."

echo "Installing vhs and ffmpeg..."
sudo apt update && sudo apt install vhs ffmpeg
```

#### 使用

**Asciinema**: https://docs.asciinema.org/getting-started/

```shell
asciinema rec demo.cast
# 退出后
asciinema play demo.cast
```

#### 对比

| 特性         | asciinema                                  | vhs (by Charm)                             |
| :----------- | :----------------------------------------- | :----------------------------------------- |
| **主要目的**   | 录制和分享终端会话                         | 将终端操作渲染成 GIF、WebM、MP4 等格式       |
| **录制方式**   | 实时捕获终端的输入输出流                   | 通过声明式配置文件 (`.tape` 文件) 定义要执行的命令和交互 |
| **输出格式**   | `.cast` (JSON 格式的文本文件)                | GIF, WebM, MP4 等视频/动画格式              |
| **播放/分享** | 通过 asciinema.org 网站嵌入式播放器、本地 `asciinema play` 命令 | 直接分享生成的 GIF/视频文件，或嵌入到网页/文档中 |
| **编辑性**    | 有限（可以修剪、调整速度，但不能修改内容）   | 高度可编辑，因为录制基于配置文件，可以随时修改命令和时序 |
| **自动化**    | 主要用于手动录制                           | 非常适合自动化生成演示和教程               |
| **文件大小**   | `.cast` 文件通常很小                       | GIF/视频文件相对较大                       |
| **交互性**    | 播放时文本可选、可复制                     | 非交互式，是视频/动画                      |
| **依赖**      | `asciinema` CLI                            | `vhs` CLI, `ffmpeg`, `ttyd` (用于渲染)       |
| **优点**      | 轻量级、文本可选、易于分享和嵌入、平台托管   | 生成美观的 GIF/视频、高度可控、适合自动化、输出格式多样 |
| **缺点**      | 依赖其平台或 CLI 播放、非标准视频格式        | 生成文件较大、非交互式、配置学习曲线         |
| **适用场景**   | 快速录制和分享真实终端操作、教程、Bug 复现 | 创建高质量的终端演示 GIF/视频、文档配图、自动化测试输出 |

asciinema可以直接在终端/本地浏览器/远程进行回放，但是想要嵌入到网页中，需要上传到asciinema.org网站上(可以选择加auth认证)，或者自己搭建player环境，稍微有些麻烦。

vhs导出的文件体积较大，也挺慢的。注意，`vhs`需要通过`rod`库下载`Chromium`浏览器，`Chromium`也不允许root用户直接运行，并且WSL也不需要图形化界面。

## Docker, Docker Compose and Kubernetes(K8s)

Docker：集装箱

Docker Compose/K8s：管理整个“港口”和“船队”（大规模容器集群）的调度系统，都是用于定义和运行多容器 Docker 应用程序的工具(一个应用程序需要多个服务时)，手动管理这些容器的启动顺序、网络连接、数据卷等会非常繁琐。这类管理工具可以简化管理操作，确保开发、测试和生产环境的配置尽可能一致。

### Docker Compose

通过`docker-compose.yml`文件定义应用的服务、网络和数据卷等配置。`docker-compose up/down`命令可以启动和停止整个应用。

- 服务 (Services)：构成应用的不同组件，每个服务通常基于一个 Docker 镜像。
- 网络 (Networks)：定义容器如何相互通信。Compose 会为你的应用创建一个默认网络，所有服务都在这个网络中，可以通过服务名称相互访问。
- 数据卷 (Volumes)：用于持久化数据，确保数据在容器重启或删除后依然存在。

### Kubernetes

个人通常用不到K8s，除非是大规模的集群管理。学习的话可以参考[k3s](https://github.com/k3s-io/k3s)。

`k3s`安装：`curl -sfL https://get.k3s.io | sh -`

K8s的高级特性：复杂的服务发现、自动扩缩容（虽然在单机上意义不大）、滚动更新策略等。

## 文档编写

### Latex

在`Unix-like-systems`，比如Linux上编译Latex似乎更快一些，所以我从Windows texlive转到了WSL2上。

**官方安装指南**：https://www.tug.org/texlive/quickinstall.html

AI翻译：参考https://github.com/Chesszyh/tongji-undergrad-thesis-template/blob/master/doc/Install-latex.md。

**太长不看版命令**：

在除 Windows 外的任何系统上进行非交互式默认安装：

```bash
cd /tmp
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
# 或者: curl -L -o install-tl-unx.tar.gz https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat < install-tl-unx.tar.gz | tar xf -
cd install-tl-2*
perl ./install-tl --no-interaction
# 可能需要几个小时才能运行结束
# 最后，将 /usr/local/texlive/YYYY/bin/PLATFORM 添加到您的 PATH 环境变量中，例如：
echo 'export PATH=$PATH:/usr/local/texlive/YYYY/bin/x86_64-linux' >> ~/.zshrc
source ~/.zshrc
```

## PPT

### Latex Slides

主要用到`beamer`，overleaf上有很多模板可以选择。

检查系统字体：

```shell
# 查看系统中文字体
fc-list :lang=zh 
# 或者更通用的关键词搜索
fc-list | grep -i -E "SimSun|SimHei|KaiTi|FangSong|Song|Hei|Kai|Ming|Noto Sans CJK|WenQuanYi|Source Han Sans"
# 查看特定字体的详细信息
fc-match -v [字体路径]
# 或者只看字体名
fc-scan --format "%{family[0]}\n" [字体路径]
```

如需下载字体，可先在Windows上安装好字体，然后移动到字体目录`/usr/share/fonts/`下。因为我一直用root运行WSL，所以字体是为全部用户安装的。
