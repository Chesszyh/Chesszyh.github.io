# Fedora

## 为什么抛弃Windows

1. 很多人评价Win11远不如Win10，我倒没什么感觉，一直更新也没炸过，这算是Windows的主要优势之一：稳定
2. 但是Windows对开发者并不十分友好：
    1. 用惯了类Unix系统的bash，Windows的cmd实在不习惯，而PowerShell语法实在是臃肿，命令太长记不住，也懒得去alias
    2. 编译工具链不友好，尤其是cpp，很多时候需要MinGW/MSYS2，Cl.exe在VS2022以外用又不是特别方便（当然，也有可能是我不会配置）
    3. 编译速度慢：Latex, CMake，明显比Linux慢；node更是比mac慢了数倍(当然，和macmini单核性能强也有关系)
    4. 错误信息不友好：莫名其妙的错误无从Debug，对于偏门问题网上很难找到有用的信息
    5. 自定义化程度低：无法对系统完全掌控，比如文件被占用就无法删除，和WSL2共用时有权限问题（xx文件删不掉）
    6. 部分AI库对Windows支持不好，比较著名的是vllm；Windows下的Python包也不如Linux丰富，conda + pip install有时会有问题，只能WSL2
3. 开启Hyper-V后，整个系统性能明显下降，预计有30%左右
4. 不明原因的占内存高，开不了几个程序内存就该吃满了（也可能是我不会配置）；新换的Linux系统，同时开3个vscode和一堆网页，内存占用也才10G
5. 将Linux作为主力系统，能更好地学习Linux相关知识，并迁移到服务器运维、OS等领域

最主要的原因，还是我的Windows系统的**权限系统**莫名其妙挂了，管理员权限无法启用，导致很多软件无法安装和运行。查阅诸多资料、进行诸多尝试都无结果，连系统修复、做启动盘都无法进行（因为都需要管理员权限）。最后进行文件备份之后直接删除了Windows系统，改用Linux。

## Linux发行版选择

1. Ubuntu

    好处是用户体量大，问题容易通过搜索引擎解决，软件发Linux包必定有deb，Ubuntu对驱动支持也好。

    但是Ubuntu默认界面太难看了，以及snap我也不喜欢。一台Thinkpad X270已经是Ubuntu了，很多云服务器也是Ubuntu，想换个不一样的。

2. Debian

    稳定，但是软件包旧，不喜欢，而且有服务器已经是debian了

3. Arch Linux

    虽然有[archinstall](https://github.com/archlinux/archinstall)脚本，但是依然担心对驱动支持不友好，以及不想经常把机器滚挂（懒得太折腾）

4. Kali Linux

    虽然是信安专业，但不影响我以后不吃这碗饭，Kali预装的工具我基本也用不上，有个虚拟机得了（而且虚拟机还安全一些）

5. Linux Mint

    没用过，以后也许可以试试

6. openSUSE

    没用过，以后也许可以试试

7. NixOS

    似乎是比较特殊的一个系统，担心软件包不全，懒得自己配置和折腾

8. Gentoo

    虚拟机装过一次，啥玩意都要编译，不想折腾，算了吧

9. Linux from Scratch

    尝试安装，但是已经烂尾了，[当前进度](https://github.com/Chesszyh/LFS)

    没这闲心折腾了，而且我也没有足够水平去定制系统

10. Fedora

    最终选择的发行版。红帽试验田，对驱动支持同样好，软件包也比较新（有时候比arch还新），默认界面换个壁纸我就很喜欢了。