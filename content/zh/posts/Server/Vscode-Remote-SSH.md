---
title: 'Vscode Remote SSH'
date: 2025-04-03T14:28:08+08:00
draft: true
categories: []
tags: []
---

<!-- 文章内容开始 -->
# Vscode Remote SSH

## Issues

### 文件修改保存权限问题

- 问题：使用vscode remote ssh用普通用户连到云服务器之后，想在本地vscode的视图下更改需要管理员权限的文件，保存时出现"Permission denied"的错误。

- 解决：
  - 直接使用root用户登录
  - 如果像AWS一样，不允许远程直接以root登录的话，可以下载"**Save as Root in Remote - SSH**"插件。使用方法：将窗格聚焦到当前修改的文件后，`Ctrl+Shift+P`输入"Save as Root`保存即可。

