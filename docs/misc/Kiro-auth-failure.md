# Kiro 登录失败：OAuth回调错误

## 问题

Linux下非deb的源代码方式安装Kiro, 使用谷歌登录后，自动跳转到`kiro://kiro.kiroAgent/authenticate-success?code=62443d12-c7f3-44c6-a722-a716b7ef6006&state=e805bdce-a6eb-4874-ba24-b683cadb2157`并使用firefox默认浏览器打开，报错：`Firefox 不知道如何打开这个地址，因为协议 (kiro) 未与任何程序关联，或此环境下不可打开该协议的地址。`

## 分析

这是典型的 OAuth 回调无法被系统默认浏览器正确处理的问题。Kiro 使用自定义协议 `kiro://` 来接收 OAuth 授权码，但 Firefox 并未配置如何处理该协议。

## 解决方案

### 方法一：AWS Builder ID

治标不治本，避免Google/GitHub登录，改用AWS Builder ID登录。

### 方法二：修复 kiro:// handler

向`~/.local/share/applications/kiro.desktop`添加以下内容：

```ini
[Desktop Entry]
Type=Application
Name=Kiro
Exec=/home/chesszyh/Applications/Kiro/bin/kiro --open-url %u # Kiro可执行文件路径
MimeType=x-scheme-handler/kiro;
Terminal=false
StartupNotify=false
```

然后更新desktop数据库：

```bash
update-desktop-database ~/.local/share/applications
```

验证handler是否注册成功：

```bash
xdg-mime query default x-scheme-handler/kiro
# 应该输出 kiro.desktop
```

也可检查快捷方式中是否已经包含Kiro。