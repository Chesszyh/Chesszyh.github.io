# 手机文件备份

## 视频、图片等备份到谷歌云盘

比如批量备份视频、图片等大文件到谷歌云盘。

### TL;DR

1. 连接手机到电脑，把大文件拷贝到电脑。
2. `rclone copy /path/to/large/files remote-name:backup-folder -P`，`-P`显示进度。

### 详细说明

浏览器上传通常是单线程 TCP 连接。在跨国高延迟（High Latency）网络下，TCP 的握手和确认机制会导致吞吐量上不去，上传大文件非常慢。我用`https://speed.cloudflare.com/`测速，上传速度有150MB/s，但是浏览器上传谷歌云盘只有1.5MB/s。所以，我们选择`rclone`多线程上传工具。

配置Google Photos远程端，命名为`my-photos`等。

```bash
rclone config
```

打开手机的`Camera`目录，具体在`mtp://HUAWEI_CLS-AL00_3AQ0224C25004704/内部存储/DCIM/Camera/`，其中`DCIM`是Digital Camera Images的缩写。由于 `mtp://`是一个虚拟协议，Rclone 无法直接识别这个开头，系统终端也无法识别这个路径，所以需要先把文件拷贝到电脑本地目录，比如`~/Videos`。然后，使用`rclone`上传：

```bash
rclone copy ~/Videos my-photos:CameraBackup -P
```

这样速度就会快很多，大概15MB/s。

## 微信聊天记录备份到电脑

手机QQ聊天记录备份支持Linux QQ，但是微信只支持Windows。如果在`vmnet-8`虚拟网卡下的Windows系统中登录微信的话，会因为手机和电脑不在`同一局域网`而无法备份。所以，要么临时将VMware的网络适配器改为桥接模式，要么就用U盘等其他备份方式。