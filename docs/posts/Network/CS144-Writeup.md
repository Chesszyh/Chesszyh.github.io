# CS144 Writeup(concise)

Last Sync: 2025-09-26, Checkpoint 0

# Checkpoint 0

用时2h左右，本次作业主要涉及环境配置、`telnet`和`netcat`模拟简单的Client/Server交互，以及对无限字节流`ByteStream`的理解和实现。

## Setup

- 基础开发环境配置

```bash
# Ubuntu
sudo apt update
sudo apt install git cmake gdb build-essential clang clang-tidy clang-format gcc-doc pkg-config glibc-doc tcpdump tshark

# Fedora
sudo dnf install git cmake gdb @development-tools clang clang-tools-extra pkgconf-pkg-config glibc-devel tcpdump wireshark-cli 
# Extra packages(maybe not needed)
sudo dnf install libubsan libasan
```

- git
  - 配置：可参考[cs144-2025-winter](https://github.com/HT4w5/minnow-winter-2025)备份仓库，创建自己的私有仓库并添加`cs144-grader`为协作者

> About Git: make frequent small commits as you work, and use commit messages that identify what changed and why.

- CS144的cpp开发准则：
  - RAII(Resource Acquisition Is Initialization)：资源获取即初始化
    - 每个对象的public接口尽量少
    - 内部有安全检查，减少误用
    - 避免“成对操作”（如 `malloc`/`free` 或 `new`/`delete`），而是通过构造/析构等自动清理资源
  - 其他比较常见的准则：
    - 避免裸指针
    - 使用`std::string`而不是C风格字符串
    - 尽可能使用`const`
  - CS144对C的底层函数进行了Modern C++封装，需要阅读`util/socket.hh`, `util/file_descriptor.hh`等头文件了解其接口

## Warmup

- 使用`telnet`建立外部连接(Role: Client): Hello World和Email sending(需要SUNet ID，故跳过)

```bash
GET /hello HTTP/1.1
Host: cs144.keithw.org
Connection: close
  # Press Enter twice after the last line
```

- 使用`netcat`建立本地连接(Role: Server): Hello World

```bash
netcat -v -l -p 9090  # Server
telnet localhost 9090 # Client
```

## Writing a network program using an OS stream socket

- Stream Socket
- Unreliable Internet always give its "best effort" to deliver `datagrams`, which is self-contained and made up of some metadata(source/destination IP/port) and payload(data, up to about 1500 bytes). 
- Endpoint OS's role: turn "best effort" datagram into "reliable" bytestream.

## (In-Memory) Reliable Byte Stream

首先为`byte_stream.hh`添加protected成员变量:

- `buffer_`：实际存储数据的容器，需要先初始化为空字符串，否则报错：`‘ByteStream::buffer_’应该在成员初始化列表中被初始化 [-Werror=effc++]`
- `closed_`：流是否已关闭
- `bytes_pushed_`：累计写入字节数
- `bytes_popped_`：累计弹出字节数

剩余部分，管理好这些成员变量状态即可。

