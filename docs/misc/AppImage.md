# AppImage

## AppImageLauncher

AppImageLauncher可以帮助管理AppImage文件，默认存储的Desktop文件和相关数据在`~/.local/share/applications/`目录下，可以修改对应`.desktop`文件的Exec字段来实现自定义启动参数。

## Snipaste

### 问题

AppImageLauncher的`.desktop`文件位于`~/.local/share/applications/`。

目前无法通过rofi启动Snipaste，直接启动appimage会报错：`qt.qpa.plugin: Could not find the Qt platform plugin "wayland" in ""`。

AppImage 的核心特点是“自包含”。它会把自己需要的大部分库（包括 Qt 框架）都打包在一起。在系统层级安装依赖库，似乎并不能解决这个问题。

我尝试提取appimage内容：`./Snipaste.AppImage --appimage-extract` 然后 `cd squashfs-root && export QT_QPA_PLATFORM=xcb; ./AppRun`：同样是启动就退出。其中`/home/chesszyh/Applications/squashfs-root/AppRun`链接到`/home/chesszyh/Applications/squashfs-root/usr/bin/Snipaste`。

已知的是Snipaste对Wayland的支持不佳，issue也没看到类似的问题，暂时不用snipaste截图了。

### 解决

现在已解决，虽然我也不知道怎么解决的。

下载Snipaste新版本AppImage(2.11.2)后，rofi可以正常启动Snipaste。

不过，Snipaste依然无法读取剪切板，这个比较烦，只能先保存再打开。TODO?