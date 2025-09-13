# Fedora Setup

- 基础安装参考博客：https://kinnari-blog.vercel.app/posts/envrionment-setup/
- 美化：参考[我的hyprland配置](https://github.com/Chesszyh/fedora-hyprland-dotfiles)。这是直接跑的[自动化安装脚本](https://github.com/JaKooLit/Fedora-Hyprland)，又进行了一些自定义修改。

## Nvidia

- 需要先关闭secure boot
- 禁用开源驱动，然后安装NVIDIA闭源驱动
- 这期间有概率会出现图形化界面卡死、黑屏等问题，google/AI去吧，怎么解决的我也忘了 :(

## ssh

```ini
# file: ~/.ssh/config
TCPKeepAlive yes # IMPORTANT!!
ServerAliveInterval 30
```