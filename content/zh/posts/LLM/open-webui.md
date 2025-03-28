---
title: 'Open Webui'
date: 2025-03-28T16:50:07+08:00
draft: false
categories: []
tags: []
---

<!-- 文章内容开始 -->
## Open Webui

TODO：

- open-webui简介
- ollama本地部署及经验

问题：open-webui还是在云服务器部署好，本地+内网穿透的话，不仅要克服GFW的问题，还要从学校内网穿出去，太麻烦了。

### 部署

```shell
# Run Open-webui for OpenAI API Usage Only
docker run -d -p 3000:8080 -e OPENAI_API_KEY="..." -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main

# Or: Run with Ollama
docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main

# 启动后不要着急访问localhost:3000，容器需要一定时间初始化、下载hf模型等等，有一个从unhealthy变为healthy的过程
```

#### 本地部署(结合cloudflare tunnel)

主要参考这篇文章：[1](https://zhuanlan.zhihu.com/p/621870045)。

#### 云端部署

TODO

### 配置

