---
title: 'Cloudflare'
date: 2025-05-09T23:37:55+08:00
draft: false
categories: ["Web", "Network"]
tags: ["Cloudflare", "CDN", "DNS"]
featuredImage: "/image/cloudflare.png"
---

<!-- 文章内容开始 -->
# Cloudflare

## Cloudflare DNS

**DNS(Domain Name System)** 是互联网的电话簿，将域名转换为IP地址。Cloudflare DNS 是一个公共DNS解析器，提供快速、安全和隐私保护的DNS服务。

仅DNS而不代理，则DNS查询会直接返回IP地址，浏览器会直接连接到目标服务器。

如果启用代理，则Cloudflare会充当中介，所有流量都会经过Cloudflare的服务器进行处理和加密。CF能够隐藏IP，[优化、缓存和保护](https://developers.cloudflare.com/fundamentals/setup/manage-domains/add-site/)请求，

如果在同一域名上有多个 A/AAAA 记录，并且其中至少有一个是代理的，Cloudflare 将把此名称上的所有 A/AAAA 记录都视为代理的。

但注意，CF代理主要针对**Web流量**，并不是万能的。比如frp，frp 协议本身不是标准的 HTTP/HTTPS 流量，那么直接通过 Cloudflare 代理这种非标准 TCP/UDP 流量可能会遇到问题，或者需要使用 Cloudflare Spectrum (付费服务) 才能正常工作。