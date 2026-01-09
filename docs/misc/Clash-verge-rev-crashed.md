# Clash-verge-rev更新后启动仪表盘时闪退

## 问题表现

在更新到 Clash-verge-rev 2.4.4 版本后，使用`clash-verge`能够正常启动clash内核并联网，但是在尝试打开Dashboard时会直接闪退。如果使用`env WEBKIT_DISABLE_COMPOSITING_MODE=1 clash-verge`启动，则可以避免闪退。

## 问题分析

- 报错信息：`Gdk-Message: Error 71 (协议错误) dispatching to Wayland display`

- 分析：Clash Verge Rev 的 Dashboard 使用 `WebKitGTK` 作为渲染引擎。`WebKitGTK` 在 Wayland 下运行时，可能遇到一些兼容性问题，导致Wayland 合成器（mutter / kwin）收到了一个非法或损坏的协议请求。Wayland 选择直接终止该连接，从而导致应用程序崩溃。

## 解决方法

找到`clash-verge`的启动脚本：

1. `/usr/share/applications/Clash-verge.desktop`：这是只读文件，需要使用root权限修改。下次更新可能会覆盖此文件。
2. `~/.local/share/applications/Clash-verge.desktop`：如果没有这个文件，可以手动创建一个，内容与`/usr/share/applications/Clash-verge.desktop`相同。读取启动脚本时，用户目录优先级应当是大于系统目录的，不会因更新而被覆盖。

修改启动脚本Exec行，添加环境变量`WEBKIT_DISABLE_COMPOSITING_MODE=1`：

```bash
Exec=env WEBKIT_DISABLE_COMPOSITING_MODE=1 clash-verge %u
```

如果改的是系统目录下的文件，需要执行：

```bash
sudo update-desktop-database
```

## 后续问题

重启后，发现clash-verge依然闪退，但是`/usr/share/applications/Clash-verge.desktop`和`~/.local/share/applications/Clash-verge.desktop`下都是正确的`Exec`行。

联想到我是使用`gnome-tweaks`管理启动应用的，怀疑是`gnome-tweaks`缓存了旧的启动配置。我将`gnome-tweaks`中Clash-verge的启动配置删除后重新添加，问题解决。