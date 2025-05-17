---
title: 'Latex'
date: 2025-05-10T15:29:08+08:00
draft: false
categories: ["Language"]
tags: ["Latex"]
---

<!-- 文章内容开始 -->
# Latex

## Quick install on Unix-like-systems

源网站：https://www.tug.org/texlive/quickinstall.html

AI翻译：参考https://github.com/Chesszyh/tongji-undergrad-thesis-template/blob/master/doc/Install-latex.md。

**太长不看**：

在除 Windows 外的任何系统上进行非交互式默认安装：

```bash
cd /tmp
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
# 或者: curl -L -o install-tl-unx.tar.gz https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat < install-tl-unx.tar.gz | tar xf -
cd install-tl-2*
perl ./install-tl --no-interaction
# 可能需要几个小时才能运行结束
# 最后，将 /usr/local/texlive/YYYY/bin/PLATFORM 添加到您的 PATH 环境变量中，例如：
echo 'export PATH=$PATH:/usr/local/texlive/YYYY/bin/x86_64-linux' >> ~/.zshrc
source ~/.zshrc
```

## Format

TODO