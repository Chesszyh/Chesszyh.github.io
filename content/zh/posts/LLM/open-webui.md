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

### 部署

```shell
# Run Open-webui for OpenAI API Usage Only
docker run -d -p 3000:8080 -e OPENAI_API_KEY="..." -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main

# 启动后不要着急访问localhost:3000，容器需要一定时间初始化、下载hf模型等等
# 有一个从unhealthy变为healthy的过程
```

### 配置

