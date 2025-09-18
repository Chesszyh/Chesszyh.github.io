# 待解决问题

- `[x]`: 已解决
- `[?]`: 不可稳定复现，最近暂时没有遇到的问题
- `[!]`: 待解决，影响使用
- `[ ]`: 待解决，不影响使用

---

- [x] 移动热点dns劫持？

Fedora:`sudo tailscale up`无反应，`nslookup controlplane.tailscale.com`解析到的IP是`198.18.1.168`（保留段），说明发生了DNS劫持。

```bash
❯ nslookup controlplane.tailscale.com
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   controlplane.tailscale.com
Address: 198.18.1.168
```

尝试解决：`sudo nano /etc/resolv.conf`，将`nameserver 127.0.0.53`注释掉，改为`nameserver 8.8.8.8`，然后重启`tailscale`服务，但是`resolv.conf`文件会被自动重置。如果想解除其他程序对`resolv.conf`的控制，可以先删除再重建该文件。我选择手动管理。

相关讨论：https://stackoverflow.com/questions/19432026/how-do-i-edit-resolv-conf

ipad连接热点之后不会发生DNS劫持，可以正常登录tailscale。考虑解决：dnscrypt-proxy或cloudflared。

---

问题已解决，应该是开了clash verge tun模式的原因, tun后DNS变为了198.18.1.0，接管了所有网络流量。

所以如果需要正常解析DNS，要关闭clash verge tun模式。

---

- [!] 输入法fcitx5 rime

rime在输入中文时，如果按了大写锁定键，之后会一直保持西文输入模式，无法切换回来，只能重启。

配置文件在`~/.local/share/fcitx5/rime`.

---

- [ ] Snipaste AppImageLauncher error

AppImageLauncher的`.desktop`文件位于`~/.local/share/applications/`。

目前无法通过rofi启动Snipaste，直接启动appimage会报错：`qt.qpa.plugin: Could not find the Qt platform plugin "wayland" in ""`。

AppImage 的核心特点是“自包含”。它会把自己需要的大部分库（包括 Qt 框架）都打包在一起。在系统层级安装依赖库，似乎并不能解决这个问题。

我尝试提取appimage内容：`./Snipaste.AppImage --appimage-extract` 然后 `cd squashfs-root && export QT_QPA_PLATFORM=xcb; ./AppRun`：同样是启动就退出。

已知的是Snipaste对Wayland的支持不佳，issue也没看到类似的问题，暂时不用snipaste截图了。

---

- [x] Linux QQ启动黑屏/无法输入中文

Linux kernel: 6.15.10-200.fc42.x86_64

* **官方 Linux QQ**（3.2.19 x86_64）无法输入中文。并且尝试截图时会直接闪退。
  * 官方版是 **Qt + 封装程序/Wine 内核混合**。
  * 优势：界面美观、功能更全面丰富，但bug也更多
  * Linux 输入法（fcitx/ibus）通过 `QT_IM_MODULE` 注入，但 QQ 内部封装后 **不识别这些环境变量**。
  * 官方 QQ 对中文输入支持似乎 **本身就很差**，属于已知限制。
* **Flatpak 版 QQ**启动后黑屏，无法正常使用。
  * Flatpak 包含自己的运行环境，和宿主系统的库、GPU 驱动隔离。
  * 我将Fedora 42 Linux内核从6.15.9更新到10之后，才出现的黑屏问题。可能是GPU 渲染/Qt runtime 与系统库不兼容

* 已尝试的解决方案

1. 修改 `/usr/share/applications/qq.desktop`：

```ini
Exec=env QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx GTK_IM_MODULE=fcitx /opt/QQ/qq %U
```

之后仍然无法输入中文。

2. 尝试禁用flatpak启动时gpu渲染等，也无效。

目前大概只能等更新了，我懒得用wine或者自己修了。这大概就是换Linux，以及更新较为激进的发行版的代价吧。

---

## [ ] 拯救固件程序破坏导致无法识别的u盘

- U盘：Thinkplus 128G
- 错误表现：插入电脑后无法识别

具体命令和输出：

- `lsblk -d -o NAME,SIZE,MODEL`: sda 0B 128GB thinkplus
    - 控制器无法正确读取到后端闪存芯片的容量信息
- `sudo dd if=/dev/zero of=/dev/sda bs=1M count=100`: dd: 打开 '/dev/sda' 失败: 找不到介质
    - 操作系统尝试向 /dev/sda 这个设备写入数据（dd写入0），但U盘的控制器返回了一个“没有存储介质”的错误。
- `sudo dmesg | tail -n 30`: 一开始，系统正确识别到了U盘的容量是126GB，但当内核尝试去读写U盘时，U盘的控制器报告说“我准备不好”或“存储介质不存在”(`Sense Key : Not Ready 和 Medium not present`)，随后发生大量的I/O错误，最终U盘的容量被识别为0。

<details>
[ 2238.982202] sd 0:0:0:0: [sda] 245760000 512-byte logical blocks: (126 GB/117 GiB)

[ 2238.982431] sd 0:0:0:0: [sda] Write Protect is off

[ 2238.982441] sd 0:0:0:0: [sda] Mode Sense: 03 00 00 00

[ 2238.982573] sd 0:0:0:0: [sda] No Caching mode page found

[ 2238.982576] sd 0:0:0:0: [sda] Assuming drive cache: write through

[ 2239.028180] sda:

[ 2239.028258] sd 0:0:0:0: [sda] Attached SCSI removable disk

[ 2239.096355] sd 0:0:0:0: [sda] tag#0 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_OK cmd_age=0s

[ 2239.096368] sd 0:0:0:0: [sda] tag#0 Sense Key : Not Ready [current]

[ 2239.096373] sd 0:0:0:0: [sda] tag#0 Add. Sense: Medium not present

[ 2239.096377] sd 0:0:0:0: [sda] tag#0 CDB: Read(10) 28 00 0e a5 ff 08 00 00 78 00

[ 2239.096380] I/O error, dev sda, sector 245759752 op 0x0:(READ) flags 0x80700 phys_seg 15 prio class 2

[ 2239.096861] sd 0:0:0:0: [sda] tag#0 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_OK cmd_age=0s

[ 2239.096865] sd 0:0:0:0: [sda] tag#0 Sense Key : Not Ready [current]

[ 2239.096868] sd 0:0:0:0: [sda] tag#0 Add. Sense: Medium not present

[ 2239.096871] sd 0:0:0:0: [sda] tag#0 CDB: Read(10) 28 00 0e a5 ff 88 00 00 38 00

[ 2239.096873] I/O error, dev sda, sector 245759880 op 0x0:(READ) flags 0x80700 phys_seg 7 prio class 2

[ 2239.097245] sd 0:0:0:0: [sda] tag#0 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_OK cmd_age=0s

[ 2239.097249] sd 0:0:0:0: [sda] tag#0 Sense Key : Not Ready [current]

[ 2239.097253] sd 0:0:0:0: [sda] tag#0 Add. Sense: Medium not present

[ 2239.097256] sd 0:0:0:0: [sda] tag#0 CDB: Read(10) 28 00 0e a5 ff 08 00 00 08 00

[ 2239.097258] I/O error, dev sda, sector 245759752 op 0x0:(READ) flags 0x0 phys_seg 1 prio class 2

[ 2239.097262] Buffer I/O error on dev sda, logical block 30719969, async page read

[ 2239.097708] sd 0:0:0:0: [sda] tag#0 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_OK cmd_age=0s

[ 2239.097711] sd 0:0:0:0: [sda] tag#0 Sense Key : Not Ready [current]

[ 2239.097715] sd 0:0:0:0: [sda] tag#0 Add. Sense: Medium not present

[ 2239.097717] sd 0:0:0:0: [sda] tag#0 CDB: Read(10) 28 00 0e a5 ff 08 00 00 08 00

[ 2239.097719] I/O error, dev sda, sector 245759752 op 0x0:(READ) flags 0x0 phys_seg 1 prio class 2

[ 2239.097722] Buffer I/O error on dev sda, logical block 30719969, async page read

[ 2239.418344] sda: detected capacity change from 245760000 to 0
</details>

由于我手头没有Windows电脑，尝试VMware win11安装DiskGenius软件修复分区表时，VMware先是识别到了u盘，但当我尝试连接的时候，先提示u盘被宿主机占用，随后这个u盘就直接在VMware里消失了。

所以：TODO：找一台别人的Windows电脑试试

参考：https://gemini.google.com/app/749ba8d6be7a984c

---

- [ ] 换启动壁纸

即使更换了Hyprland，默认启动时依然是Fedora的祖传壁纸，并不太好看。假设你想使用的壁纸是`mizuki-gdm.jpg`：

我第一次尝试以下修改方案，发现没用，应该是针对GDM而不是SDDM的。

```bash
# All these commands need sudo
cd /usr/share/backgrounds # 这是壁纸存放目录
# 备份原始壁纸
sudo cp /usr/share/backgrounds/f42/default/f42-01-day.jxl ~/f42-01-day.bak.jxl
sudo cp /usr/share/backgrounds/f42/default/f42-01-night.jxl ~/f42-01-night.bak.jxl

# Fedora 默认用的是 jxl 格式的图片，jpg 也能识别
sudo cp mizuki-gdm.jpg /usr/share/backgrounds/f42/default/f42-01-day.jxl
sudo cp mizuki-gdm.jpg /usr/share/backgrounds/f42/default/f42-01-night.jxl

# 更新链接
sudo ln -sf ./f42/default/f42-01-day.jxl default.jxl
sudo ln -sf ./f42/default/f42-01-night.jxl default-dark.jxl

# 重启 GDM，或者下次登录时生效
sudo systemctl restart gdm
```

SDDM:

```bash
cat /etc/sddm.conf | grep "Current=" # 查看当前主题
```

参考资源：https://cn.linux-terminal.com/?p=7826