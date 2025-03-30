---
title: 'Change_log'
date: 2025-03-27T12:00:18+08:00
draft: false
categories: []
tags: []
---

<!-- 文章内容开始 -->
## 3.30

- [x] Openai-api-proxy(API中转)
  - 参考Docker那篇博客。似乎不是很难。
- [x] Open-Webui部署+域名
- [ ] Chessboard+Stockfish

## 3.29

喜报：昨天部署Open-webui导致AWS EC2实例OOM，今天在阿里云上编译Stockfish，把2核2G服务器也干OOM了；除此之外我还在自己Ubuntu 8G笔记本上编译了一下试试，结果也给卡死了，哈哈哈

## 3.28

> 突然想出国了，国内这网络环境真受不了了。Docker拉不下来，git/curl有时候各种SSL之类的报错，Chatgpt有一阵子还老弹人机验证/莫名其妙报错，时间全浪费在网络上面了。
> 除此之外，校园网卡的感觉也比较严

- [x] Open Webui云端部署
  - 服务器太差，docker一起来就经常OOM，甚至卡到ssh都连不上

TODO：

- [ ] HTTPS/Openai API转发：用AWS做个机场/api中转站？
- [x] Cloudflare Tunnel内网穿透，用本地pc部署open-webui
