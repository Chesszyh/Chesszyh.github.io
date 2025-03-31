---
title: 'Cusdis'
date: 2025-03-31T11:22:29+08:00
draft: false
categories: []
tags: []
---

<!-- 文章内容开始 -->
# Cusdis 部署

## Docker

```shell
docker run \
  -d \
  -e USERNAME=chesszyh \
  -e PASSWORD="jn3K*9HGk1#fNI" \
  -e JWT_SECRET="jn3K*9HGk1#fNI" \
  -e DB_URL=file:/data/db.sqlite \
  -e NEXTAUTH_URL=db-for-server.cvuia666kyfi.us-east-2.rds.amazonaws.com \
  -p 6000:3000 \
  -v /data:/data \
  djyde/cusdis
```

## Railway

