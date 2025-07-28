# 待解决问题

## 移动热点dns劫持？

Fedora:`sudo tailscale up`无反应，`nslookup controlplane.tailscale.com`解析到的IP是`198.18.0.10`（保留段），说明发生了DNS劫持。

尝试解决：`sudo nano /etc/resolv.conf`，将`nameserver 127.0.0.53`注释掉，改为`nameserver 8.8.8.8`，然后重启`tailscale`服务，但是`resolv.conf`文件会被自动重置。如果想解除其他程序对`resolv.conf`的控制，可以先删除再重建该文件。我选择手动管理。

但是，现在DNS似乎无法正确解析了：![alt text](image.png)

可能后续还是得恢复原始配置。不过我是真想不通为什么无法解除DNS劫持状态？

相关讨论：https://stackoverflow.com/questions/19432026/how-do-i-edit-resolv-conf

ipad连接热点之后不会发生DNS劫持，可以正常登录tailscale。考虑解决：dnscrypt-proxy或cloudflared。

## Fedora

### fedora dnf error

官方源404，据说是官方问题……清华源403,阿里云可以正常下载。没明白为什么

