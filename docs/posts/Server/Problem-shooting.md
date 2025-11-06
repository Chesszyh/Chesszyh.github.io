# Problem Shooting

## 误封ssh端口导致无法连接服务器

很愚蠢的问题，起因是我让AI写一个`iptables`脚本，来管理[copilot-api](https://github.com/ericc-ch/copilot-api)项目的4141端口访问权限（这个项目没有鉴权功能，如果直接公网部署，相当于所有人都可以调用我的copilot API），结果AI写的脚本把ssh端口22也给封了，我窗口关掉之后就再也连不上服务器了。

我尝试使用Digital Ocean的Recovery Console功能，但发现我不知道root的密码（因为我用的是ssh key登录），所以我只能进入Recovery mode，通过ISO启动、挂载磁盘，然后修改`/etc/iptables.rules`文件，解除对22端口的封锁。

进入临时救援系统后：

```bash
# 找到主系统分区，我的是 /dev/vda1
fdisk -l 

# 挂载系统
mkdir /mnt/rescue
mount /dev/vda1 /mnt/rescue
mount --bind /dev /mnt/rescue/dev
mount --bind /proc /mnt/rescue/proc
mount --bind /sys /mnt/rescue/sys
chroot /mnt/rescue

# 清除 iptables 规则
iptables -F
iptables -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# 保存规则
iptables-save > /etc/iptables.rules

# 退出 chroot 并卸载
exit
umount /mnt/rescue/dev /mnt/rescue/proc /mnt/rescue/sys /mnt/rescue
```

然后回到Recovery控制台，重新选择从硬盘启动，然后再重启后就能连接服务器了。
