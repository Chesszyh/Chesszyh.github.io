# Tmux

`tmux` 是一个强大的终端复用器 (terminal multiplexer)，它允许你在单个终端窗口中创建、访问和控制多个终端会话。即使你断开 SSH 连接或关闭了本地终端，`tmux` 中的会话和正在运行的程序也会继续在后台运行。

---

## 基本概念

*   **服务器 (Server)**：当你第一次启动 `tmux` 时，它会在后台启动一个服务器进程。所有会话、窗口和窗格都由这个**服务器**管理。
*   **会话 (Session)**：**一个会话是一组窗口的集合**。你可以创建多个会话，并在它们之间切换。会话可以在你断开连接后继续存在。
*   **窗口 (Window)**：一个**窗口**占据整个终端屏幕，可以看作是浏览器中的一个标签页。
*   **窗格 (Pane)**：一个窗口可以被分割成多个独立的**窗格**，每个窗格都是一个独立的伪终端。
---

## 快速上手命令

### 1️⃣ 创建与连接会话

| 命令                               | 作用           |
| -------------------------------- | ------------ |
| `tmux`                           | 创建一个新会话      |
| `tmux new -s mysession`          | 创建并命名会话      |
| `tmux attach`                    | 连接最近的会话      |
| `tmux attach -t mysession`       | 连接指定会话       |
| `tmux ls`                        | 列出所有会话       |
| `tmux detach`                    | 断开当前会话（后台运行） |
| `tmux kill-session -t mysession` | 关闭会话         |
| `tmux kill-server`               | 关闭所有 tmux 会话 |

---

### 2️⃣ 进入 tmux 后的快捷键操作

默认前缀键是 **`Ctrl+b`**（类似 Vim 的 leader key）。
以下命令都要 **先按下 Ctrl+b，然后再按下后一个键**。

#### 💡 窗口（window）操作

| 快捷键                     | 功能             |
| ----------------------- | -------------- |
| `Ctrl+b c`              | 新建窗口           |
| `Ctrl+b ,`              | 重命名当前窗口        |
| `Ctrl+b n` / `Ctrl+b p` | 切换到下一个 / 上一个窗口 |
| `Ctrl+b w`              | 列出所有窗口选择       |
| `Ctrl+b &`              | 关闭当前窗口         |
| `Ctrl+b 0~9`            | 直接跳转到指定编号窗口    |

#### 💡 面板（pane）操作

| 快捷键          | 功能           |
| ------------ | ------------ |
| `Ctrl+b %`   | 垂直分割窗口       |
| `Ctrl+b "`   | 水平分割窗口       |
| `Ctrl+b o`   | 在面板间切换       |
| `Ctrl+b x`   | 关闭当前面板       |
| `Ctrl+b ;`   | 切换到上一个面板     |
| `Ctrl+b 方向键` | 按方向切换面板      |
| `Ctrl+b z`   | 最大化 / 还原当前面板 |

#### 💡 面板布局与调整

| 快捷键                     | 功能                |
| ----------------------- | ----------------- |
| `Ctrl+b 空格`             | 切换不同布局（平铺、左右、上下等） |
| `Ctrl+b {` / `Ctrl+b }` | 交换面板位置            |
| `Ctrl+b Alt+方向键`        | 调整面板大小（部分终端支持）    |

---

### 3️⃣ 复制与粘贴模式（Scrollback）

| 快捷键               | 功能            |
| ----------------- | ------------- |
| `Ctrl+b [`        | 进入复制模式（可上下滚动） |
| 方向键 / PgUp / PgDn | 移动光标          |
| `空格`              | 开始选中          |
| `Enter`           | 复制选中内容        |
| `Ctrl+b ]`        | 粘贴到当前光标处      |

---

## 自定义配置

配置文件路径：`~/.tmux.conf`

```bash
# 设置前缀为 Ctrl+a（更像 screen）
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# 开启鼠标支持
set -g mouse on

# 状态栏样式
set -g status-bg black
set -g status-fg green

# 面板边框颜色
set -g pane-border-style fg=blue
set -g pane-active-border-style fg=yellow

# 窗口编号从1开始
set -g base-index 1
setw -g pane-base-index 1

# 复制模式使用vi键位
setw -g mode-keys vi
```

加载配置：

```bash
tmux source-file ~/.tmux.conf
```

---

## 实用技巧

### 🌱 启动自定义会话

```bash
tmux new -s dev -n editor "nvim" \; split-window -h "htop"
```

👉 启动名为 `dev` 的会话，左边运行 Neovim，右边运行 htop。

---

### 🔁 自动恢复上次会话

可在 `.bashrc` 或 `.zshrc` 添加：

```bash
if [ -z "$TMUX" ]; then
  tmux attach -t default || tmux new -s default
fi
```

自动进入上次会话或新建一个。

---

### 📋 与系统剪贴板交互（Linux）

需要安装 `xclip` 或 `wl-clipboard`：

```bash
bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -sel clip"
```

---

## 进阶命令

| 命令                                      | 功能        |
| --------------------------------------- | --------- |
| `tmux rename-session newname`           | 重命名会话     |
| `tmux list-panes`                       | 查看当前面板    |
| `tmux swap-pane -U / -D`                | 移动面板顺序    |
| `tmux resize-pane -L / -R / -U / -D 10` | 调整大小      |
| `tmux capture-pane -p`                  | 输出面板内容    |
| `tmux save-buffer ~/log.txt`            | 保存复制缓冲区内容 |
