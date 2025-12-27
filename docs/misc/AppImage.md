# AppImage

## AppImageLauncher

AppImageLauncher可以帮助管理AppImage文件，默认存储的Desktop文件和相关数据在`~/.local/share/applications/`目录下，可以修改对应`.desktop`文件的Exec字段来实现自定义启动参数。

## Snipaste

`/home/chesszyh/Applications/squashfs-root/AppRun`->`/home/chesszyh/Applications/squashfs-root/usr/bin/Snipaste`，才是启动Snipaste的正确方式。下载Snipaste新版本AppImage后，直接点击似乎并没有覆盖原有的squashfs-root目录。所以如何进行更新呢？

另外，Snipaste也无法读取剪切板。TODO