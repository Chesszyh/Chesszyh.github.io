# 拯救固件程序破坏导致无法识别的u盘

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