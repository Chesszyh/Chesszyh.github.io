---
title: 'Vim'
date: 2025-04-03T15:13:05+08:00
draft: true
categories: []
tags: []
---

<!-- 文章内容开始 -->
# Vim

一般只有两个用途：

1. 服务器上没别的可用了，我又不喜欢nano，那就vim吧
2. Windows下，在不打开IDE的情况下要创建代码文件时，可以直接地址栏`pwsh`然后`vim`启动。windows-vim我还配置了copilot，挺方便的。

## 杂记

### 复制粘贴

参考：https://blog.csdn.net/to_free/article/details/115187981

- vim内复制：`y`
- vim内粘贴：`p`
- 从系统剪切板粘贴：normal下`"*p`
- 复制到系统剪切板：normal下`"+y`