---
title: 'WSL'
date: 2025-04-12T20:56:01+08:00
draft: true
categories: []
tags: []
---

<!-- 文章内容开始 -->
# WSL2

> “最好的Linux发行版”
> 我还没用过arch linux，听说很难安装，哪天在虚拟机里弄一个

## Setting

参考：https://learn.microsoft.com/en-us/windows/wsl/wsl-config

WSL主要有两个配置文件：`wsl.conf`(位于机器内部`/etc/wsl.conf`，应用于WSL1和WSL2)和`wslconfig`(全局配置，应用于所有**WSL2**发行版，不含WSL1；位于Windows系统`C:\Users\<username>\.wslconfig`)。配置文件生效一般需要重启WSL，`wsl --terminate <distroName>`只关闭特定机器，`wsl --shutdown`关闭**所有**WSL2发行版。关机命令执行后需要等一会再开机，可用`wsl --list --running`或者`wsl -l -v`检查是否关闭成功。

### wsl.conf

Demo：

```ini
# Automatically mount Windows drive when the distribution is launched
[automount]

# Set to true will automount fixed drives (C:/ or D:/) with DrvFs under the root directory set above. Set to false means drives won't be mounted automatically, but need to be mounted manually or with fstab.
enabled = true

# Sets the directory where fixed drives will be automatically mounted. This example changes the mount location, so your C-drive would be /c, rather than the default /mnt/c. 
root = /

# DrvFs-specific options can be specified.  
options = "metadata,uid=1003,gid=1003,umask=077,fmask=11,case=off"

# Sets the `/etc/fstab` file to be processed when a WSL distribution is launched.
mountFsTab = true

# Network host settings that enable the DNS server used by WSL 2. This example changes the hostname, sets generateHosts to false, preventing WSL from the default behavior of auto-generating /etc/hosts, and sets generateResolvConf to false, preventing WSL from auto-generating /etc/resolv.conf, so that you can create your own (ie. nameserver 1.1.1.1).
[network]
hostname = DemoHost
generateHosts = false
generateResolvConf = false

# Set whether WSL supports interop processes like launching Windows apps and adding path variables. Setting these to false will block the launch of Windows processes and block adding $PATH environment variables.
[interop]
enabled = false
appendWindowsPath = false

# Set the user when launching a distribution with WSL.
[user]
default = DemoUser

# Set a command to run when a new WSL instance launches. This example starts the Docker container service.
[boot]
command = service docker start
systemd=true # Enable systemd，need version 0.67.6+
```

- `systemctl list-unit-files --type=service`：输出系统上所有 systemd 服务的概览，输出结果中`STATE`的可能值：
  - `enabled`：自启动
  - `disabled`：禁用，且不会自启动
  - `static`：没有启用或禁用信息，通常由其他服务或目标文件激活
  - `masked`：被屏蔽，无法启动
  - `generated`：动态生成的服务
  - `enabled-runtime`：服务在运行时启用，重启后失效
  - `indirected`：服务通过其他单元文件间接启用

### wslconfig

Demo: 

```ini
# Settings apply across all Linux distros running on WSL 2
[wsl2]

# Limits VM memory to use no more than 4 GB, this can be set as whole numbers using GB or MB
memory=4GB 

# Sets the VM to use two virtual processors
processors=2

# Specify a custom Linux kernel to use with your installed distros. The default kernel used can be found at https://github.com/microsoft/WSL2-Linux-Kernel
kernel=C:\\temp\\myCustomKernel

# Specify the modules VHD for the custum Linux kernel to use with your installed distros.
kernelModules=C:\\temp\\modules.vhdx

# Sets additional kernel parameters, in this case enabling older Linux base images such as Centos 6
kernelCommandLine = vsyscall=emulate

# Sets amount of swap storage space to 8GB, default is 25% of available RAM
swap=8GB

# Sets swapfile path location, default is %USERPROFILE%\AppData\Local\Temp\swap.vhdx
swapfile=C:\\temp\\wsl-swap.vhdx

# Disable page reporting so WSL retains all allocated memory claimed from Windows and releases none back when free
pageReporting=false

# Turn on default connection to bind WSL 2 localhost to Windows localhost. Setting is ignored when networkingMode=mirrored
localhostforwarding=true

# Disables nested virtualization
nestedVirtualization=false

# Turns on output console showing contents of dmesg when opening a WSL 2 distro for debugging
debugConsole=true

# Enable experimental features
[experimental]
sparseVhd=true
```

我当前的配置：

```ini
[wsl2]
memory=10GB
swap=4GB
# localhostforwarding=true # 启用默认连接，将 WSL 2 的 localhost 绑定到 Windows 的 localhost（当 networkingMode=mirrored 时此设置被忽略）(?)

[experimental]
autoMemoryReclaim=gradual  # gradual  | dropcache | disabled
networkingMode=mirrored
dnsTunneling=true
firewall=true
autoProxy=true
sparseVhd=true
```

## Proxy

我用的是Clash Verge(on win11)+Ubuntu24.04(WSL2)。clash verge默认代理端口似乎不是7890而是7897？折腾了半天，发现在`~/.zshrc`加上

网上找了一堆教程，

## Source

- `apt`：`/etc/apt/sources.list.d/ubuntu.sources`
- 

## Database

### Vscode Database插件连接WSL数据库



