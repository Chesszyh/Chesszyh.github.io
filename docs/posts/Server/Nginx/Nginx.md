# Nginx

TODO，以后用到再补充笔记

## nginx自动配置

经常手动修改nginx配置文件比较麻烦，所以我打算写一个脚本来自动生成和修改nginx配置文件。

- [x] nginx自动配置？已经有人做了
  - 我设想的Script: `nginx_auto -d [domain] -p [port]`
  - 其实确实也只需要`domain`和`port`就可以了

参考：NginxProxyManager

## Tips

我是之前用authelia（这个资源占用非常低，但是配置稍微麻烦）现在用authentik（这个是图形化且身份管理很方便，还能身份注册）做身份验证，然后用nginx-proxy-manager来反代

然后让这几个容器挂载同一个文件夹以实现协同工作，不协同就挂载不同的文件夹