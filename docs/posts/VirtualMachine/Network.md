# Network

## 虚拟机内连接主机7897代理

- 主机(Windows11)：
  - 首先通过`ipconfig`查看`VMNet 8`虚拟网关地址，我的是`192.168.67.1`
  - Clash-verge，代理在7897端口，**注意需要打开`局域网连接(LAN)`**，即让代理监听 `0.0.0.0:7897` 而不仅仅是 `127.0.0.1:7897`。
    - 与此同时我还开了`Tun`模式，开了之后才能连上`gemini`
  - **Windows 防火墙默认会阻止来自虚拟机的入站连接**，因此需要在防火墙中添加一个规则，允许来自虚拟机的入站连接到7897端口。以管理员身份启动PowerShell：

```shell
New-NetFirewallRule -DisplayName "Allow Clash on VMnet" -Direction Inbound -Protocol TCP -LocalPort 7897 -Action Allow
```

- 虚拟机：设置网络代理

```shell
# filepath: /etc/environment
http_proxy="http://192.168.67.1:7897"
https_proxy="http://192.168.67.1:7897"
all_proxy="socks5://192.168.67.1:7897"
HTTP_PROXY="http://192.168.67.1:7897"
HTTPS_PROXY="http://192.168.67.1:7897"
ALL_PROXY="socks5://192.168.67.1:7897"
no_proxy="localhost,127.0.0.1"
NO_PROXY="localhost,127.0.0.1"
```

然后运行测试：`curl -v 192.168.67.1:7897`和`curl -v https://www.google.com`，如果能正常返回内容，则说明设置成功。

