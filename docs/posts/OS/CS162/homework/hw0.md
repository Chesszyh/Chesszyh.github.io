# [Homework 0](https://cs162.org/static/hw/hw-intro/docs/setup/docker-workspace/)

## Setup

### Docker Workspace Setup, with password-avoid-entry

```bash
git clone https://github.com/Berkeley-CS162/cs162-workspace
cd cs162-workspace
docker compose up -d
# Generate a new SSH key pair if you don't have one
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_4096 -N ""
# id_rsa_4096.pub should be replaced with your own public key
ssh-copy-id -p 16222 -i ~/.ssh/id_rsa_4096.pub workspace@127.0.0.1
```

Add this block to `~/.ssh/config`:

```bash
Host cs162-workspace
  HostName 127.0.0.1
  Port 16222
  User workspace
  IdentityFile ~/.ssh/id_ed25519
```

### Github auto-grader setup

需要Student ID，所以暂时跳过。

### Workspace Configuration

国内需要首先`export http_proxy=http://host.docker.internal:7897 && export https_proxy=http://host.docker.internal:7897`（`host.docker.internal`是由容器内部自动解析为宿主机的IP地址，`7897`是你的代理端口，注意代理软件需要开启`允许局域网访问`），配置科学上网。

### Auto-grader

目前应该是无法使用官方测试框架，只能本地测试。


