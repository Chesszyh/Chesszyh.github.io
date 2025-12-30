# Arch Linux

## Resources

- [archinstall-自动安装脚本](https://github.com/archlinux/archinstall)
- [我第一次安装参考的教程](https://blog.csdn.net/OceanWaves1993/article/details/130467985)

## Install on Thinkpad X270

使用`archinstall`在7年前的实体机上安装arch linux.

### 制作启动U盘

首先制作启动镜像：`sudo dd if=archlinux-x86_64.iso of=/dev/sda bs=4M status=progress oflag=sync`，其中`/dev/sda`是U盘设备，注意不要加分区号`sda1`等。

!!! warning
    这个命令会**清空U盘**，请确认`/dev/sda`是U盘设备而不是硬盘设备。并且，执行该命令前无须手动格式化U盘（即使该U盘之前做过启动盘）。

然后启动电脑，按F1进入BIOS，UEFI/Legacy Boot → `UEFI Only`，Secure Boot → `Disabled`。

然后按F12选择从U盘启动，进入到live系统。

### 启动安装

首先联网。校园网似乎认证有些复杂，我直接连手机热点：

```bash
# 启动iwctl
iwctl

# 在iwctl中执行以下命令
device list                    # 查看无线网卡设备名（通常是wlan0）
station wlan0 scan            # 扫描网络
station wlan0 get-networks    # 显示可用网络
station wlan0 connect "Mate 70"  # 连接你的热点，并输入密码
quit                          # 退出iwctl
```

然后`ping -c 3 archlinux.org`测试网络是否通畅。

联网之后就可以启动`archinstall`了：

<details>
<summary>archinstall安装选项</summary>

<ol>
  <li>
    Archinstall language
    <br>
    选择：English。简体中文似乎会导致命令行乱码。
  </li>
  <li>
    Keyboard layout
    <br>
    选择：us 或 cn
  </li>
  <li>
    Mirror region
    <br>
    选择：China （选择中国镜像源加速下载）
  </li>
  <li>
    Locales
    <br>
    选择：en_US.UTF-8 和 zh_CN.UTF-8
  </li>
  <li>
    Disk configuration
    <br>
    选择：Use a best-effort default partition layout
    <br>
    选择你的硬盘（通常是 /dev/sda 或 /dev/nvme0n1）
    <br>
    文件系统建议选择：ext4 或 btrfs(更现代化，支持快照等功能，但兼容性稍差)
  </li>
  <li>
    Bootloader
    <br>
    选择：Grub （推荐，兼容性好）
  </li>
  <li>
    Swap
    <br>
    选择：True （建议启用，特别是内存较小时）
  </li>
  <li>
    Hostname
    <br>
    输入你想要的主机名，如：thinkpad-arch
  </li>
  <li>
    Root password
    <br>
    设置root用户密码（建议设置强密码）
  </li>
  <li>
    User account
    <br>
    创建普通用户账户<br>
    设置用户名和密码
  </li>
  <li>
    Profile
    <br>
    选择桌面环境，我选择Hyprland（一个现代化的动态平铺窗口管理器）
  </li>
  <li>
    Audio
    <br>
    选择：Pipewire （现代音频系统）
  </li>
  <li>
    Kernels
    <br>
    保持默认：linux
  </li>
  <li>
    Additional packages
    <br>
    可以添加常用软件，但是从上到下翻页找太麻烦了，不如安装完系统后再用<code>pacman -S</code>安装需要的软件包。
  </li>
  <li>
    Network configuration
    <br>
    选择：NetworkManager （图形界面网络管理）
  </li>
  <li>
    Timezone
    <br>
    选择：Asia/Shanghai
  </li>
  <li>
    Automatic time sync (NTP)
    <br>
    选择：True
  </li>
</ol>

</details>

安装完成后，重启电脑，拔掉U盘，进入到新安装的Arch Linux系统。

### 系统配置

首先，依然是联网：`sudo nmtui`，选择你的无线网络并连接。

然后安装clash-verge-rev。

#### clash-verge-rev

初次安装我遇到了一点问题，AUR源里似乎默认没这个包，`makepkg -si`时出现超时错误，估计又是国内网络问题。解决方案：利用国外云服务器起一个arch docker容器，编译好后把生成的包传回来安装。

```bash
# You're on your cloud server now
docker run -it --name arch -v $PWD:/mnt archlinux bash 

# You're now the root user in container
# 由于makepkg不允许root用户运行，所以创建一个普通用户
useradd -m test # 加-m 创建家目录
passwd -d test # 不设置密码，可以直接 su 过去
echo "test ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
su - test

# You're now the `test` user in container
git clone https://aur.archlinux.org/clash-verge-rev-bin.git
cd clash-verge-rev-bin
makepkg -s

# After the package is built, exit the container and copy the package to your local machine
docker cp arch:/home/test/clash-verge-rev-bin/clash-verge-rev-bin-*.pkg.tar.zst .

# Back to your local arch linux
scp root@178.128.217.160:/root/clash-verge-rev-bin-2.4.2-1-x86_64.pkg.tar.zst .

sudo pacman -U clash-verge-rev-bin-2.4.2-1-x86_64.pkg.tar.zst
```

这样就解决网络问题了。

#### Hyprland config

直接偷懒用了[脚本](https://github.com/JaKooLit/Arch-Hyprland)。我的fedora也是用这个作者的脚本配置的，省事。

```bash
sh <(curl -L https://raw.githubusercontent.com/JaKooLit/Arch-Hyprland/main/auto-install.sh)
```

这个脚本可以执行大部分的系统配置工作，下面的部分可能会与脚本重复。

!!!note
    安装步骤支持缓存，但有的步骤在老机器上依然会卡很久，比如`quickshell`（基于Qt/QML的现代shell工具包，需要编译Qt组件）。

!!!danger
    脚本选项不能盲目全选。比如`rog`，这是专门针对华硕笔记本的配置，你是华硕吗？

#### 字体

中文支持（避免乱码）：

```bash
sudo pacman -S noto-fonts-cjk noto-fonts-emoji wqy-zenhei wqy-microhei
fc-cache -fv
```

霞鹜文楷：TODO 设置成主字体？

#### 进一步配置

<details>  
<summary>Click to expand</summary>

```bash
{% include "../../../scripts/arch-init.sh" %}
```
</details>

## Installation on WSL2

比较简单，参考：https://wiki.archlinuxcn.org/wiki/%E5%9C%A8_WSL_%E4%B8%8A%E5%AE%89%E8%A3%85_Arch_Linux

```shell
wsl --update
wsl --install archlinux
```

WSL默认会安装到C盘，可以更改其安装位置：

```shell
wsl --export archlinux D:\archlinux.tar
wsl --unregister archlinux # 卸载原来的WSL
wsl --import Arch-Linux D:\WSL2\Arch-Linux D:\archlinux.tar --version 2
Remove-Item D:\archlinux.tar
wsl --set-default Arch-Linux
```

## Installation on VMWare

下载ISO后，**设置BIOS从ISO启动，需要勾选`已连接`和`启动时连接`**。

### 配置网络

```shell
# 创建网络配置文件
# filepath: /etc/systemd/network/20-wired.network
cat > /etc/systemd/network/20-wired.network <<EOF
[Match]
Name=ens33

[Network]
DHCP=yes
EOF

# 启用 systemd-networkd 服务
systemctl enable systemd-networkd systemd-resolved

# 为了让域名解析正常工作，需要将系统的 DNS 配置链接到 systemd-resolved
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# 再次检查ip
ip a

# 测试
ping www.baidu.com
```

### 配置静态 IP 地址

> 这步弄完之后，不知道为什么无法连接到网络了，所以我选择了回滚并暂时不使用静态 IP 地址。

```shell
# filepath: /etc/systemd/network/20-wired.network
[Match]
Name=ens33

[Network]
Address=192.168.2.140/24
Gateway=192.168.67.0    # 必须是 VMWare 虚拟网络的正确网关地址
DNS=223.5.5.5       # 阿里云
DNS=119.29.29.29    # 腾讯云
```

### 配置 SSH

```shell
# 安装 OpenSSH
pacman -S openssh
# 修改配置文件: /etc/ssh/sshd_config中，`PermitRootLogin` 改为 `yes`

# 设置开机启动
systemctl enable sshd
systemctl start sshd
```

遇到问题：指纹错误导致主机拒绝连接

```shell
PS D:\Git\Project\Information-Security\Linux> ssh root@192.168.67.130
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
SHA256:AFyLwX21uJhxPbmd00CrrHMtyc20OvXCaaDBPHGN1fY.
Please contact your system administrator.
Add correct host key in C:\\Users\\zyh2005/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in C:\\Users\\zyh2005/.ssh/known_hosts:79
Host key for 192.168.67.130 has changed and you have requested strict checking.
Host key verification failed.
```

解释：`WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!`说明`192.168.67.130`的机器指纹已经改变(重装系统导致的)，再次用同一个主机 IP 地址去连接时，主机出于安全考虑（防止中间人攻击）拒绝了连接。

只需要删除`.ssh/known_hosts`文件中对应的行即可。

### 创建普通用户

```bash
useradd -m chesszyh
passwd chesszyh
pacman -S sudo
# 编辑 sudoers 文件
EDITOR=vim visudo

# 找到`%wheel ALL=(ALL) ALL`这一行，取消注释

# 将`chesszyh`用户添加到`wheel`组
usermod -aG wheel chesszyh
```

### 安装引导加载程序 (Bootloader)

```shell
# 1. 安装 GRUB 软件包
pacman -S grub

# 2. 将 GRUB 安装到硬盘的主引导记录 (MBR)
#    注意：是安装到 /dev/sda (整个硬盘)，而不是 /dev/sda1 或 /dev/sda2 (分区)
grub-install --target=i386-pc /dev/sda

# 3. 生成 GRUB 配置文件
grub-mkconfig -o /boot/grub/grub.cfg
```

### 安装桌面

以下参考[偏日常使用的 Arch Linux 桌面环境教程](https://arch.icekylin.online/guide/rookie/desktop-env-and-app)。

```bash
# 安装显示服务器来绘制窗口和图形
# pacman -S xorg-server

# 安装KDE Plasma桌面环境
pacman -S plasma-meta konsole dolphin # plasma-meta 元软件包、konsole 终端模拟器和 dolphin 文件管理器。plasma会默认安装xorg。
```

AI推荐选择：

1. `qt6-multimedia-ffmpeg`
2. `noto-fonts`
3. `phonon-qt6-vlc`

```shell
# 配置并启动greeter sddm
systemctl enable sddm
systemctl start sddm
```

## 其他问题

### 调整分区大小

虚拟机从20G调整到40G后，分区大小没有自动调整。

先扩展分区：

```shell
sudo pacman -S parted
sudo parted /dev/sda
print   # 打印分区表，发现/dev/sda总大小40G，但/dev/sda1只有20G
resizepart 2 100% # 调整分区2大小到100%，注意选择实际/dev/sda2的分区号
quit   # 退出parted
```

再扩展文件系统：

```shell
sudo resize2fs /dev/sda2
df -h # 查看分区大小，/dev/sda2应该变成40G了
```


