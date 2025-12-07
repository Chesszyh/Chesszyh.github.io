# Tailscale

## Trouble shooting

解决`tailscale up`或`tailscale login`卡住的问题。

### 问题原因

测试`ping controlplane.tailscale.com`失败。因为 tailscaled 作为 systemd 服务，不读取环境变量`HTTPS_PROXY=http://127.0.0.1:7897`。而我的clash-verge-rev开启了Tun模式，接管全局流量，这导致了tailscaled无法访问外网，因为它没有走 Clash 代理。

### 解决方法

让tailscaled走clash代理即可。

1. 确认 tailscaled.service 的真实位置

```bash
systemctl status tailscaled | grep Loaded
# Output:
# Loaded: loaded (/usr/lib/systemd/system/tailscaled.service; enabled; preset: disabled)
```

2. 在 `/etc/systemd/system/tailscaled.service.d/` 下创建 override 文件：

```bash
sudo mkdir -p /etc/systemd/system/tailscaled.service.d
sudo nano /etc/systemd/system/tailscaled.service.d/override.conf
```

写入：

```ini
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7897"
Environment="HTTPS_PROXY=http://127.0.0.1:7897"
Environment="ALL_PROXY=http://127.0.0.1:7897"
```

重新加载：

```bash
sudo systemctl daemon-reload
sudo systemctl restart tailscaled
```

再次尝试登录：

```bash
sudo tailscale up
```

这次成功弹出登录链接，没有再卡住。