---
title: 'Open Webui'
date: 2025-03-28T16:50:07+08:00
draft: false
categories: []
tags: []
featuredImage: "/image/open-webui.png"
---

<!-- 文章内容开始 -->
# Open Webui

TODO：

- open-webui简介
- ollama本地部署及经验

问题：open-webui还是在云服务器部署好，本地+内网穿透的话，不仅要克服GFW的问题，还要从学校内网穿出去，太麻烦了。

## 部署

```shell
# Run Open-webui for OpenAI API Usage Only
docker run -d -p 3000:8080 -e OPENAI_API_KEY="..." -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main

# Or: Run with Ollama
docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main

# 启动后不要着急访问localhost:3000，容器需要一定时间初始化、下载hf模型等等，有一个从unhealthy变为healthy的过程
```

### 本地部署(结合cloudflare tunnel)

主要参考这篇文章：[1](https://zhuanlan.zhihu.com/p/621870045)。目前内网相互访问仍有一些问题，可能需要抛弃该方案。

### 云端部署

也不难，注意端口开放规则+Nginx反向代理+避免OOM(可增加交换空间?)即可。

### 模型配置

- Openai:
- 除Openai外模型：
  - [ ] Claude
  - [ ] Gemini
  - [ ] Deepseek

### HTTPS协议配置及问题

使用麦克风和摄像头时，必须通过HTTPS协议。参考该[Issue](https://github.com/open-webui/open-webui/discussions/3012)。

具体部署参考了本篇教程：[在AWS EC2 (Amazon Linux 2023) 上结合nginx配置https](https://www.cnblogs.com/johnnyzhao/p/17572919.html)

**问题**：`SyntaxError: Unexpected token 'd', "data: {"id"... is not valid JSON`

### Web Search

[Googl PSEs](https://docs.openwebui.com/tutorials/web-search/google-pse/)

## 用户管理

用户身份(Root/User/Deactivated)、权限组管理、模型管理

[新注册用户找不到本地模型](https://github.com/open-webui/open-webui/discussions/10047)：需要在`Admin Setting-Models`里手动开放各个模型权限，否则即使加入权限组也没有任何模型权限。

[Locked out password](https://github.com/open-webui/open-webui/discussions/1027)：管理员密码忘了？重开吧！