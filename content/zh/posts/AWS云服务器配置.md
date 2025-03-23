---
title: 'AWS云服务器配置'
date: 2025-03-23T16:55:36+08:00
draft: true
categories: ["Cloud Server", "Web"]
tags: ["AWS", "Linux", "Server"]
---

我手头有一堆Linux设备，WSL2-Ubuntu24.04/Thinkpad-X270-Ubuntu22.04/AWS和阿里云服务器/Kali-Linux虚拟机，每次换新的都得重新配环境，有点烦

之前记过的笔记也是乱七八糟不知道去哪找，还是发在博客比较好。

命令全是针对Ubuntu系统的，别的系统不熟。

## Amazon Web Services (AWS)

### Storage

AWS Free Tier 通过 Amazon Elastic Block Store (EBS) 提供 30 GB 的存储、200 万 I/O 以及 1 GB 的快照存储。默认8G实在是太少了，想扩容发现控制台页面有点看不懂，参考了一下YouTube视频：[How to increase EBS volume size in AWS EC2](https://www.youtube.com/watch?v=jVffXZc4tf8)，该视频主要参考了[AWS的官方文档](https://docs.aws.amazon.com/ebs/latest/userguide/recognize-expanded-volume-linux.html)。

```shell
# 安装必要的工具
sudo apt install cloud-guest-utils gdisk -y   # Ubuntu/Debian

# 扩展分区
sudo growpart /dev/xvda 1

# 扩展文件系统
sudo resize2fs /dev/xvda1   # 对于 ext4
# 或
sudo xfs_growfs /          # 对于 xfs

# 验证扩展结果
df -h
```

### Connect

通常我使用`ssh -i "AWS-Cloudserver.pem" ubuntu@ec2-3-14-128-59.us-east-2.compute.amazonaws.com`，自动登录到ubuntu普通用户。

AWS提供了四种连接方式，我懒得去深入了解，就让AI简单解释了一下：

1. EC2 Instance Connect：基于浏览器的 SSH 连接方式，使用使用临时SSH密钥，自动管理
2. Session Manager：高安全性，通过 `AWS Systems Manager` 控制台连接到实例，无需暴露22端口，默认似乎没有安装SSM Agent
3. SSH密钥对：开放22端口，管理好本地私钥就好
4. EC2 串行控制台：低级别系统访问，通常用于系统启动失败、网络配置错误等紧急故障排除的情景

`AWS-Cloudserver.pem`密钥文件，我在WSL2的`/root/`下放了一份，又在`/mnt/d/下载`放了一份，但是在Windows上使用PEM文件连接时报错：

```shell
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Permissions for 'AWS-Cloudserver.pem' are too open.
It is required that your private key files are NOT accessible by others.
This private key will be ignored.
Load key "AWS-Cloudserver.pem": bad permissions
ubuntu@ec2-3-14-128-59.us-east-2.compute.amazonaws.com: Permission denied (publickey).
```

还挺智能，电脑居然能检测到我把密钥放在这里不安全(确实是不安全，以后不犯懒了hh)因此拒绝连接，设置为仅当前用户可访问即可：

```powershell
icacls "D:\下载\AWS-Cloudserver.pem" /inheritance:r
icacls "D:\下载\AWS-Cloudserver.pem" /grant:r "$($env:USERNAME):(R,W)"
# 或者chmod 600：只有文件所有者有读写权限
```

## Shell

### [Zsh shell](https://github.com/fish-shell/fish-shell)

- 配置参考：
  - [zsh](https://www.hackerneo.com/blog/dev-tools/better-use-terminal-with-zsh)

```shell
# 之前安装的是fish，但fish似乎不太兼容bash语法？所以就换成了zsh
# 这是fish的安装命令
sudo apt-add-repository ppa:fish-shell/release-4
sudo apt update
sudo apt install fish

# ---------------------------------------------------------
# zsh
sudo apt install zsh
# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# 修改主题：[powerlevel10k](https://github.com/romkatv/powerlevel10k)
# 然后根据提示进行配置即可
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 修改~/.zshrc文件中的ZSH_THEME和plugins
vim ~/.zshrc
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
    # other plugins...
    zsh-autosuggestions
    zsh-syntax-highlighting
    z
)
# 安装插件
# autosuggestions, syntax-highlighting, z(文件夹快捷跳转)
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 使修改生效
source ~/.zshrc
```

### [copilot.vim](https://github.com/github/copilot.vim)

```shell
# 安装unzip(如果没有)
apt install -y unzip
# 安装nodejs
apt install -y nodejs npm

# 或者安装fnm
# curl -o- https://fnm.vercel.app/install | zsh
# source ~/.zshrc
# 然后使用 fnm 安装 Node.js
# fnm install 16  # 安装 Node.js 16 (Copilot 兼容版本)
# fnm use 16

# 安装copilot.vim
git clone https://github.com/github/copilot.vim.git \
  ~/.vim/pack/github/start/copilot.vim

# Start Vim/Neovim and invoke :Copilot setup
```

## Language

### [uv](https://docs.astral.sh/uv/getting-started/)

uv：先进的Python虚拟环境管理器，很像Rust的Cargo。

- Python自带venv：共享解释器，我不是很喜欢这个方案，除非conda出现问题用不了
  - *之前WSL2-Ubuntu创建conda虚拟环境后直接pip安装，会报PEP668(禁止在全局base环境下执行pip安装)的错，`which pip`显示的是系统而非conda虚拟环境的pip，猜测可能是`conda init`时有问题，后续也不知道怎么就解决了*
- conda隔离性更好，每个虚拟环境有自己的独立解释器，ML和DL常用

```shell
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.zshrc
# 创建指定 Python 版本的虚拟环境
uv venv -p python3.11 ./venv
source ./venv/bin/activate
uv pip install [package]
uv pip install -r requirements.txt
# 取消激活虚拟环境
deactivate
```

### [Miniconda](https://www.anaconda.com/docs/getting-started/miniconda/install)

[Anaconda](https://www.anaconda.com/products/individual)自带大量数据科学库（pandas, numpy, scipy, scikit-learn等），体积比较大，服务器存储空间有限时一般用Miniconda。

如果通过curl/wget等下载脚本有各种网络问题时，也可以手动下载后上传到服务器，不过手动上传的文件需要注意`chmod +x`。我在国内的电脑和服务器，git https协议pull不下来也push不上去，只能用ssh；ping github也ping不通，curl更是几乎没成功过。国外的AWS服务器，git clone简直就是秒下，流畅性差距简直不是一般的大。

Miniconda安装脚本是一个**自解压可执行脚本**，它包含:

1. 一个文本shell脚本部分：执行逻辑，以及用户协议等
2. 一个附加的二进制数据部分(包含实际的安装文件)

> 我第一次下载脚本时，一看`.sh`文件居然266MB，用Emeditor和Notepad++打开都有乱码(二进制数据)，试图用`dos2unix`将LF转为CRLF也会报错：`unix2dos: Binary symbol 0x02 found at line 670 \n unix2dos: Skipping binary file`

```shell
# 下载
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```

## Docker

[Reference](https://docs.docker.com/engine/install/ubuntu/)

```shell
# 1. Set up Docker's apt repository.

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

# 2. Install Docker packages.
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin\

# 3. Verify that Docker Engine is installed correctly by running the hello-world image.
docker run hello-world
```

## 其他工具

```shell
# ncdu: headless下磁盘空间占用查看，类似Windows的WiZTree
sudo apt install ncdu

```

## Service

### Open-webui

```shell
# Run Open-webui for OpenAI API Usage Only
docker run -d -p 3000:8080 -e OPENAI_API_KEY="..." -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
```

## Check

```shell
# 系统信息
uname -a                    # 内核版本
cat /etc/os-release         # 操作系统版本
uptime                      # 运行时间和负载

# 硬件资源
free -h                     # 内存使用情况
df -h                       # 磁盘使用情况
lscpu                       # CPU 信息
vmstat 1 5                  # 系统资源状态

# 网络配置
ip addr                     # 网络接口
netstat -tulpn              # 开放端口
curl -I localhost           # 检查 web 服务
ss -tuln                    # 查看监听端口

# 服务状态
systemctl list-units --type=service --state=running  # 运行中的服务
sudo systemctl status nginx # 检查 Nginx 状态（如果有）
sudo systemctl status apache2 # 检查 Apache 状态（如果有）

# 安全检查
sudo fail2ban-client status # 防护状态(如已安装)
cat /var/log/auth.log | grep Failed # 登录失败记录
ls -la ~/.ssh/authorized_keys # 检查 SSH 密钥

# 日志检查
tail -n 50 /var/log/syslog  # 系统日志
journalctl -xe             # 系统日志(systemd)

# Web 服务器配置检查
nginx -t                   # Nginx 配置检查
apache2ctl -t              # Apache 配置检查

# 性能监控
top -b -n 1                # 进程资源使用
iostat -x 1 5              # 磁盘 I/O 性能
```