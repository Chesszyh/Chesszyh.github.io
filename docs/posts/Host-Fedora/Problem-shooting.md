# Problem Shooting

## X11兼容

最近形式语言与自动机，需要用JFLAP.jar，初次启动报错：

```bash
Exception in thread "main" java.awt.HeadlessException: No X11 DISPLAY variable was set, or no headful library support was found, but this program performed an operation which requires it,
```

解决方案：下载完整的OpenJDK，然后强制Java通过XWayland渲染。

```bash
# 搜索可用的OpenJDK版本
sudo dnf search openjdk

# 我选择安装java21
sudo dnf install java-21-openjdk java-21-openjdk-devel java-21-openjdk-headless

# 检查XWayland是否启动
ps aux | grep Xwayland

# java GUI依赖
sudo dnf install gtk3 libXext libXrender libXtst libXi libX11

# 带参运行JFLAP
env GDK_BACKEND=x11 \ # 强制 Java 通过 X11 渲染
    _JAVA_AWT_WM_NONREPARENTING=1 \ # 适配非传统窗口管理器（如 Hyprland）
    DISPLAY=:0 \ # 显式指定 XWayland 的显示接口
    java -Dawt.useSystemAAFontSettings=on \
            -Dswing.aatext=true \
            -jar JFLAP7.1.jar
```

或者制作启动脚本：

```bash
#!/usr/bin/env bash
export GDK_BACKEND=x11
export DISPLAY=:0
export _JAVA_AWT_WM_NONREPARENTING=1

java -Dawt.useSystemAAFontSettings=on \
     -Dswing.aatext=true \
     -jar path/to/JFLAP7.1.jar
```

