> Summarized by Claude Sonnet 4

# Fedora系统zram虚拟内存配置完整指南

## 配置zram的详细步骤

### 方法1：使用systemd-zram-generator（推荐）

```bash
# 1. 安装zram工具（通常已预装）
sudo dnf install zram-generator

# 2. 创建配置文件
sudo tee /etc/systemd/zram-generator.conf << EOF
[zram0]
zram-size = ram / 2
compression-algorithm = lz4
EOF

# 3. 重新加载systemd配置并启动
sudo systemctl daemon-reload
sudo systemd-zram-generator
sudo systemctl start systemd-zram-setup@zram0.service

# 4. 验证配置
swapon --show
free -h
```

### 方法2：手动配置zram

```bash
# 1. 加载zram模块
sudo modprobe zram

# 2. 设置压缩算法
echo lz4 | sudo tee /sys/block/zram0/comp_algorithm

# 3. 设置设备大小
echo 2G | sudo tee /sys/block/zram0/disksize

# 4. 格式化并启用
sudo mkswap /dev/zram0
sudo swapon /dev/zram0

# 5. 设置开机自启（创建systemd服务）
sudo tee /etc/systemd/system/zram-swap.service << EOF
[Unit]
Description=Enable zram swap
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/bin/bash -c 'modprobe zram && echo lz4 > /sys/block/zram0/comp_algorithm && echo 2G > /sys/block/zram0/disksize && mkswap /dev/zram0 && swapon /dev/zram0'
ExecStop=/bin/bash -c 'swapoff /dev/zram0 && echo 1 > /sys/block/zram0/reset && modprobe -r zram'

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable zram-swap.service
```

## 常见问题排查方法

### 1. 设备占用错误排查

```bash
# 检查设备状态
lsblk | grep zram
swapon --show
cat /proc/swaps

# 检查设备是否被挂载或占用
mount | grep zram
sudo lsof /dev/zram0
sudo fuser -v /dev/zram0

# 检查相关服务状态
systemctl status "*zram*"
systemctl list-units | grep zram
```

### 2. 设备重置方法

```bash
# 软重置（如果设备未被占用）
echo 1 | sudo tee /sys/block/zram0/reset

# 硬重置（完全重新加载模块）
sudo modprobe -rf zram
sudo modprobe zram num_devices=1
```

### 3. 配置验证命令

```bash
# 验证zram设备配置
cat /sys/block/zram0/comp_algorithm
cat /sys/block/zram0/disksize
cat /sys/block/zram0/mem_used_total

# 验证swap状态
free -h
swapon --show
cat /proc/swaps
```

### 4. 日志查看

```bash
# 查看systemd服务日志
journalctl -u systemd-zram-setup@zram0.service
journalctl -xeu systemd-zram-setup@zram0.service

# 查看系统日志中的zram信息
dmesg | grep -i zram
```

## 为什么实际内存和swap小于预期？

### 内存 15.4G < 16G 的原因：

1. **硬件预留内存**
   - 集成显卡占用内存（通常512MB-2GB）
   - BIOS/UEFI预留内存
   - 硬件保护区域

2. **内核预留**
   - DMA缓冲区
   - 内核代码和数据结构
   - 中断向量表

3. **计算单位差异**
   - 硬件厂商：1GB = 1000³ 字节
   - 操作系统：1GB = 1024³ 字节
   - 16GB硬件 ≈ 14.9GiB 系统可用

### swap 7.7G < 8G 的原因：

1. **压缩开销**
   - zram需要额外的元数据存储
   - 压缩算法索引表
   - 设备管理结构

2. **对齐和预留**
   - 内存页面对齐要求
   - 系统预留缓冲区
   - 管理数据结构占用

3. **实际可用空间**
   - 8GB物理分配
   - ~300MB管理开销
   - ≈ 7.7GB实际可用空间

## 优化建议

### 性能调优

```bash
# 调整swap使用倾向（0-100，默认60）
echo 10 | sudo tee /proc/sys/vm/swappiness
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# 查看压缩率
cat /sys/block/zram0/mm_stat
```

### 大小建议

- **8GB+ RAM系统**：zram设置为RAM的25-50%
- **4-8GB RAM系统**：zram设置为RAM的50-100%  
- **<4GB RAM系统**：zram设置为RAM的100-200%

## 总结

zram通过内存压缩技术提供高效的虚拟内存，避免了传统swap的磁盘I/O瓶颈。配置过程中的"设备忙"错误通常表明设备已正确配置并在使用中，这是正常的保护机制。内存和swap的实际大小小于标称值是由于系统开销、硬件预留和计算单位差异造成的正常现象。