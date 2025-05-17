---
title: 'Tmux'
date: 2025-05-09T23:26:42+08:00
draft: false
categories: ["Shell"]
tags: ["Tmux"]
featuredImage: "/image/tmux.png"
---

<!-- 文章内容开始 -->
# Tmux

## 太长不看版(快捷命令)

- `c`：创建新窗口
- `n`：下一个窗口
- `p`：上一个窗口
- `ctrl+b` + `n(数字)`：切换到第 n 个窗口

## Gemini对Tmux的介绍

`tmux` 是一个强大的终端复用器 (terminal multiplexer)，它允许你在单个终端窗口中创建、访问和控制多个终端会话。即使你断开 SSH 连接或关闭了本地终端，`tmux` 中的会话和正在运行的程序也会继续在后台运行。

以下是 `tmux` 的详细用法：

### 1. 基本概念

*   **服务器 (Server)**：当你第一次启动 `tmux` 时，它会在后台启动一个服务器进程。所有会话、窗口和窗格都由这个服务器管理。
*   **会话 (Session)**：一个会话是一组窗口的集合。你可以创建多个会话，并在它们之间切换。会话可以在你断开连接后继续存在。
*   **窗口 (Window)**：一个窗口占据整个终端屏幕，可以看作是浏览器中的一个标签页。一个会话可以包含多个窗口。
*   **窗格 (Pane)**：一个窗口可以被分割成多个独立的窗格，每个窗格都是一个独立的伪终端。

### 2. 安装

在大多数 Linux 发行版中，你可以使用包管理器安装 `tmux`：

*   **Debian/Ubuntu**: `sudo apt update && sudo apt install tmux`
*   **CentOS/RHEL**: `sudo yum install tmux` 或 `sudo dnf install tmux`
*   **macOS (使用 Homebrew)**: `brew install tmux`

### 3. 核心操作与快捷键

`tmux` 的操作主要依赖于一个**前缀键 (Prefix Key)**，默认是 `Ctrl+b`。按下前缀键后，再按下一个字符键来执行相应的命令。

#### a. 会话管理 (Session Management)

在**终端命令行**中执行以下命令 (不需要先进入 `tmux` 环境)：

*   **启动新会话**:
    ```bash
    tmux
    ```
    或者，启动一个有名字的会话 (推荐)：
    ```bash
    tmux new -s <session_name>
    # 例如: tmux new -s myproject
    ```
*   **列出所有会话**:
    ```bash
    tmux ls
    ```
*   **附加 (Attach) 到已存在的会话**:
    *   附加到最近的会话：
        ```bash
        tmux attach
        # 或者 tmux a
        ```
    *   附加到指定名称的会话：
        ```bash
        tmux attach -t <session_name>
        # 例如: tmux attach -t myproject
        ```
    *   附加到指定会话 ID (通常是数字，从 `tmux ls` 输出中获取)：
        ```bash
        tmux attach -t <session_id>
        # 例如: tmux attach -t 0
        ```
*   **分离 (Detach) 当前会话** (回到普通终端，但会话仍在后台运行)：
    *   快捷键 (在 `tmux` 环境内)：`Ctrl+b` 然后按 `d`
*   **杀死 (Kill) 会话**:
    *   杀死指定名称的会话：
        ```bash
        tmux kill-session -t <session_name>
        ```
    *   杀死所有会话：
        ```bash
        tmux kill-server
        ```
    *   在 `tmux` 环境内杀死当前会话：
        `Ctrl+b` 然后输入 `:kill-session` 回车。

#### b. 窗口管理 (Window Management)

在 `tmux` 环境内执行以下操作 (先按 `Ctrl+b`，再按对应字符)：

*   **创建新窗口**: `c`
*   **切换到下一个窗口**: `n` (next)
*   **切换到上一个窗口**: `p` (previous)
*   **按编号切换窗口**: `0` 到 `9` (例如，`Ctrl+b` 然后 `1` 切换到第 1 个窗口)
*   **列出所有窗口 (并选择)**: `w` (window list)
*   **重命名当前窗口**: `,` (逗号)，然后输入新名称并回车。
*   **关闭当前窗口**: `&` (会提示确认)

#### c. 窗格管理 (Pane Management)

在 `tmux` 环境内执行以下操作 (先按 `Ctrl+b`，再按对应字符)：

*   **垂直分割当前窗格 (左右)**: `%`
*   **水平分割当前窗格 (上下)**: `"` (双引号)
*   **在窗格间切换**:
    *   `o`: 按顺序切换到下一个窗格。
    *   方向键 (`↑`, `↓`, `←`, `→`): 切换到指定方向的窗格。
*   **调整窗格大小**:
    *   按住 `Ctrl+b` 不放，然后按方向键 (`↑`, `↓`, `←`, `→`)。
    *   或者 `Ctrl+b` 然后 `:` 进入命令模式，输入 `resize-pane -D 10` (向下扩展10行)，`-U` (向上)，`-L` (向左)，`-R` (向右)。
*   **最大化/还原当前窗格 (Zoom)**: `z` (再次按下可还原)
*   **关闭当前窗格**: `x` (会提示确认)
*   **交换窗格位置**:
    *   `{`: 与上一个窗格交换。
    *   `}`: 与下一个窗格交换。
*   **显示窗格编号**: `q` (按对应数字可快速切换到该窗格)

#### d. 复制模式 (Copy Mode) / 滚动

`tmux` 有自己的复制粘贴机制，并且允许你向上滚动查看历史输出。

*   **进入复制模式**: `[`
    *   进入复制模式后，你可以使用方向键、`PageUp`/`PageDown` 来滚动屏幕。
    *   Vim 模式 (默认可能不是，但可以配置)：
        *   `k`, `j`, `h`, `l` 移动光标。
        *   `Ctrl+u` / `Ctrl+d` 上下翻页。
        *   `g` 到顶部，`G` 到底部。
*   **开始选择文本 (在复制模式中)**:
    *   Emacs 模式 (默认)：`Ctrl+Space`
    *   Vim 模式：`Space`
    *   移动光标选择文本。
*   **复制选中文本 (在复制模式中)**:
    *   Emacs 模式：`Alt+w`
    *   Vim 模式：`Enter`
*   **粘贴最近复制的内容**: `]`
*   **退出复制模式**: `q` 或 `Enter` (如果未选择文本)

#### e. 其他常用命令

*   **显示时钟**: `t` (再按任意键消失)
*   **显示所有快捷键绑定**: `?`
*   **进入命令模式**: `:` (可以输入 `tmux` 命令，例如 `kill-window`)

### 4. 配置文件 (`~/.tmux.conf`)

你可以通过创建和编辑 `~/.tmux.conf` 文件来自定义 `tmux` 的行为和快捷键。

例如，更改前缀键为 `Ctrl+a` (类似 GNU Screen)：
```tmux
# ~/.tmux.conf
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix
```

启用鼠标支持 (滚动、选择窗格/窗口)：
```tmux
# ~/.tmux.conf
set -g mouse on
```

修改分割窗格的快捷键：
```tmux
# ~/.tmux.conf
bind | split-window -h # 垂直分割 (左右)
bind - split-window -v # 水平分割 (上下)
```
修改配置后，需要让 `tmux` 重新加载配置文件。可以在 `tmux` 环境内按 `Ctrl+b` 然后输入 `:source-file ~/.tmux.conf` 回车，或者直接重启 `tmux` 服务。

### 5. 实用技巧

*   **命名会话和窗口**：使用有意义的名称可以帮助你更好地管理多个项目。
    *   `tmux new -s project_name`
    *   `Ctrl+b` `,` 重命名窗口
*   **状态栏 (Status Bar)**：`tmux` 底部有一个状态栏，显示当前会话、窗口、时间等信息。可以高度自定义。
*   **脚本化 `tmux`**：你可以编写 shell 脚本来自动化创建复杂的 `tmux` 工作区布局。

`tmux` 功能非常丰富，以上是最常用和核心的部分。多加练习，你会发现它能极大地提高你在终端工作的效率。建议从基本操作开始，逐步探索更高级的功能和自定义选项。