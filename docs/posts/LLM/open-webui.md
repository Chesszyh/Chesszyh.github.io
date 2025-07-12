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

## 部署

### 使用Docker

```shell
# Run Open-webui for OpenAI API Usage Only
docker run -d -p 3000:8080 -e OPENAI_API_KEY="..." -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main

# Or: Run with Ollama
docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main

# 启动后不要着急访问localhost:3000，容器需要一定时间初始化、下载hf模型等等，有一个从unhealthy变为healthy的过程
```

- 本地部署：需要结合cloudflare tunnel做内网穿透，主要参考这篇[文章](https://zhuanlan.zhihu.com/p/621870045)。但目前校园网内无法相互访问，已经抛弃此方案。

- 云端部署：服务器上方便一些，注意端口开放规则+Nginx反向代理，并且注意避免OOM(可增加交换空间)即可。定位`open-webui的内存占用过大，导致服务器ssh进不去`这个问题，我花了很长时间……

### 使用pip

```shell
conda create -n open-webui python=3.11 # 官网推荐指定3.11版本
conda activate open-webui
pip install open-webui
```

做服务的话，感觉还是docker方便一些。

## 配置

Open-webui原生只支持Ollama和OpenAI模型，Anthropic/Google/Deepseek等其他模型厂商可通过[function](https://docs.openwebui.com/features/plugin/functions/)功能实现。open-webui社区还是非常活跃的，这三个模型的函数调用都已经有人实现了。除了基础模型的扩展，还有更多其他功能可用。

### HTTPS协议配置及问题

> 使用 ai.neurosama.uk，会不会让网站看起来更高级一些……？

使用麦克风和摄像头时，必须通过HTTPS协议。参考该[Issue](https://github.com/open-webui/open-webui/discussions/3012)。

HTTPS具体部署参考了本篇教程：[在AWS EC2 (Amazon Linux 2023) 上结合nginx配置https](https://www.cnblogs.com/johnnyzhao/p/17572919.html)

**问题**：`SyntaxError: Unexpected token 'd', "data: {"id"... is not valid JSON`

**解决**：我使用了`nginx`，根据issue区讨论，修改`nginx.conf`文件如下：

```json
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

    server {
        listen 80;
        server_name ai.neurosama.uk;  # 配置你的域名

        location / {
            # Websockets
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_pass http://127.0.0.1:3000;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Disable buffering for the streaming responses (SSE)
            chunked_transfer_encoding off;
            proxy_buffering off;
            proxy_cache off;
            
            # Connection Timeouts (1hr)
            keepalive_timeout 3600;
            proxy_connect_timeout 3600;
            proxy_read_timeout 3600;
            proxy_send_timeout 3600;
        }
    }

    server {
        listen 443 ssl;
        server_name ai.neurosama.uk;

        ssl_certificate /etc/letsencrypt/live/ai.neurosama.uk/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/ai.neurosama.uk/privkey.pem;

        # 可选：优化 SSL 配置
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-SHA256:AES128-GCM-SHA256:AES128-SHA256';
        ssl_prefer_server_ciphers on;
        
        location / {
            # Websockets
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_pass http://127.0.0.1:3000;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Disable buffering for the streaming responses (SSE)
            chunked_transfer_encoding off;
            proxy_buffering off;
            proxy_cache off;
            
            # Connection Timeouts (1hr)
            keepalive_timeout 3600;
            proxy_connect_timeout 3600;
            proxy_read_timeout 3600;
            proxy_send_timeout 3600;
        }
    }


    # Settings for a TLS enabled server.
    # server {
    #     listen       443 ssl;
    #     listen       [::]:443 ssl;
    #     http2        on;
    #     server_name  _;
    #     root         /usr/share/nginx/html;

    #     ssl_certificate "/etc/pki/nginx/server.crt";
    #     ssl_certificate_key "/etc/pki/nginx/private/server.key";
    #     ssl_session_cache shared:SSL:1m;
    #     ssl_session_timeout  10m;
    #     ssl_ciphers PROFILE=SYSTEM;
    #     ssl_prefer_server_ciphers on;

    #     # Load configuration files for the default server block.
    #     include /etc/nginx/default.d/*.conf;

    #     error_page 404 /404.html;
    #     location = /404.html {
    #     }

    #     error_page 500 502 503 504 /50x.html;
    #     location = /50x.html {
    #     }
    # }
}
```

### Function

本地运行的话，直接点几下按钮就行。服务在云端的话，似乎稍微有些问题：

1. 先下载json再从云端控制台导入，会出现`[object Object],[object Object],[object Object]`这种看不懂的奇怪报错；
2. 默认导入`localhost:8080`，如果修改成云服务器ip+端口再直接导入的话，就不会出问题。

### Web Search

[Googl PSEs](https://docs.openwebui.com/tutorials/web-search/google-pse/)

### Image Generation

- [配置问题解决](https://github.com/open-webui/open-webui/discussions/10029)
- [Google参考](https://ai.google.dev/gemini-api/docs/image-generation?hl=zh-cn#rest)

### Document

#### Apache Tika

TODO

Tika：处理文档的工具，支持多种格式的文档解析。

## 权限管理

用户身份(Root/User/Deactivated)、权限组管理、模型管理

[新注册用户找不到本地模型](https://github.com/open-webui/open-webui/discussions/10047)：需要在`Admin Setting-Models`里手动开放各个模型权限，否则即使加入权限组也没有任何模型权限。

[Locked out password](https://github.com/open-webui/open-webui/discussions/1027)：管理员密码忘了？重开吧！

## 其他常见问题

- 函数导入后，保存时报错：`Only alphanumeric characters and underscores are allowed in the id`：
  - 解决：手动修改函数名就好，open-webui对函数名有特殊限制。参考：https://github.com/open-webui/open-webui/issues/6471

