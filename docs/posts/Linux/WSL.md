# WSL2

> “最好的Linux发行版”

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

我用的是Clash Verge(on win11)+Ubuntu24.04(WSL2)。clash verge默认代理端口不是7890而是7897，设置对应代理即可。

### WSL2的容器连接主机7897代理

WSL2 内的 `Docker` 容器网络与 WSL2 本身的网络是隔离的，它位于更深一层的 NAT 网络（`172.18.0.0/16`，根据`ip a`输出）中，无法直接访问 `192.168.67.1`网关。因此，我们需要使用一个特殊的 DNS 名称：`host.docker.internal`。这个地址由 Docker 自动解析为 Windows 宿主机的内部 IP 地址。

我们可以在容器启动时通过`docker run -e http_proxy="http://host.docker.internal:7897" -e https_proxy="http://host.docker.internal:7897" -e all_proxy="socks5://host.docker.internal:7897" -e no_proxy="localhost,127.0.0.1" <image_name>`来设置代理，也可以在容器内部设置环境变量：

```shell
export http_proxy="http://host.docker.internal:7897"
export https_proxy="http://host.docker.internal:7897"
```

运行测试`ping host.docker.internal`和`ping www.google.com`(如果容器没有`curl`)，如果能正常返回内容，则说明设置成功。

### WSL2中配置Docker GPU环境和下载镜像

参考：[Install NVIDIA Container Toolkit on WSL2](https://gist.github.com/atinfinity/f9568aa9564371f573138712070f5bad)

## Source

- `apt`：`/etc/apt/sources.list.d/ubuntu.sources`



