# Database

## Setup

### Issues

- Vscode + WSL2 + Mysql无法连接？参考[Access denied for user 'root'@'localhost' 的解决](https://stackoverflow.com/questions/41645309/mysql-error-access-denied-for-user-rootlocalhost): `ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';`
- Cmake安装依赖后编译，异常终止编译过程后再次执行编译命令报错：可以手动修改被污染的`.cmake`文件。以后可以在配置完依赖后执行`git commit`，保存一次当前环境；后续如果文件夹发生移动等问题，直接`git reset --hard`回到上次提交的状态即可。

### OceanBase

[OceanBase](https://hub.docker.com/r/oceanbase/oceanbase-ce)：designed for users to quickly set up an OceanBase environment for testing purposes. Single-instance cluster only and NOT for Kubernetes.

> 占用资源比较大，6G内存+?G存储(我看报错日志里显示需要14G现有11G，说明ODB实际需要的存储空间比14G应该还大)，只能在我PC上跑。学校也给了替代方案：MariaDB。

```shell
# 1. 镜像启动(参考官方文档)

# Deploy a mini mode instance
docker run -p 2881:2881 --name oceanbase-ce -d oceanbase/oceanbase-ce

# Deploy an instance to utilize the full resource of the container
docker run -p 2881:2881 --name oceanbase-ce -e MODE=normal -d oceanbase/oceanbase-ce

# Deploy an instance using fastboot mode
docker run -p 2881:2881 --name oceanbase-ce -e MODE=slim -d oceanbase/oceanbase-ce

# Execute init SQL scripts after bootstrap, do not change root user's password in SQL scripts.
# If you'd like to change root user's password, use variable OB_TENANT_PASSWORD.
docker run -p 2881:2881 --name oceanbase-ce -v {init_sql_folder_path}:/root/boot/init.d -d oceanbase/oceanbase-ce

# If you want to specify root's password, then add: `   123456`
# Verify the bootstrap completion by running:
docker logs oceanbase-ce | tail -1 # Expected output: "boot success!"

# 2. 进入镜像内部，连接数据库
docker exec -it oceanbase-ce bash
obd cluster display obcluster # 查看集群状态

# 参考上条命令输出结果，直接复制粘贴以下命令
obclient -h172.17.0.2 -P2881 -uroot -Doceanbase -A # 连接数据库(命令仅作示例)
# 进入数据库后，检查连接是否成功
show databases
```

连接成功后，可以对container进行简单配置。做作业的时候，感觉手动敲SQL的各种命令和条目名实在是太麻烦了，tab也没有，自动补全也没有，于是就想找一些便捷的工具。JetBrains提供了DataGrip，我下载了但还没用，如果vscode能行的话我就不打算用重型IDE了。我的个人PC开启了Hyper-v虚拟化+VMWare+WSL2+Docker，多个虚拟化环境同时运行，感觉对windows本身的性能还是有一些影响的(有时仅开一个vscode+chrome就会把内存吃到90%以上，更别提JB家的IDE了)。

#### 为运行中的无端口映射容器添加端口映射

我的`oceanbase/oceanbase-ce`是直接在docker desktop的`run`按钮拉取的，默认似乎没有暴露任何端口，也没有设置root密码，导致在vscode-Database插件连接时遇到了`connect ETIMEDOUT`问题。所以我就想：如何为运行中的无端口映射容器添加端口映射？

最简单的方法，就是重启容器，再重新运行`run`命令添加相关参数。

```shell
# 停止容器
docker ps # 输出c674655f0a94   oceanbase/oceanbase-ce:latest ...
# 创建容器数据备份（可选）
# docker commit c674655f0a94 oceanbase_backup
docker stop c674655f0a94
docker run -p 2881:2881 --name oceanbase-ce -e MODE=slim -d oceanbase/oceanbase-ce -e OB_TENANT_PASSWORD=xxx
```

或者利用[nginx-proxy](https://github.com/nginx-proxy/nginx-proxy)仓库提供的解决方案：

```shell
docker run --detach --name nginx-proxy --publish 80:80 --volume /var/run/docker.sock:/tmp/docker.sock:ro nginxproxy/nginx-proxy:1.7
# 启动你的应用容器，并设置VIRTUAL_HOST环境变量
docker run --detach --name your-proxied-app --env VIRTUAL_HOST=http://database.neurosama.uk/ nginx
```

目前暂不成功的方式：使用socat(Socket Cat)创建端口转发。注意socat是**将宿主机的端口流量转发到容器**，因此需要安装在**宿主机**而非容器内部！

```shell
sudo apt-get install socat
# 获取容器IP，并设置为临时变量
CONTAINER_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' 容器ID)
# 在宿主机上创建端口转发：TCP-LISTEN为本机端口，TCP:$CONTAINER_IP为转发到的容器IP和端口;
# 不加nohup，关闭终端后socat自动被kill掉
nohup socat TCP-LISTEN:2882,fork TCP:$CONTAINER_IP:2882 & # fork: 当接收到连接时，创建一个子进程处理连接，并允许处理多个并发连接
```

#### ODB Issues

1. `obd cluster display obcluster` >> `[ERROR] Another app is currently holding the obd lock.` or `No such deploy: obcluster.`

```shell
# 使用ps查找obd进程
[root@56ed25840bc6 ~]# ps aux | grep obd
root      1521  5.5  0.0  10888   980 ?        S    13:03   0:00 obd cluster tenant create obcluster -n test -o express_oltp        
root      1523 12.3  0.7 236488 60072 ?        Sl   13:03   0:01 obd cluster tenant create obcluster -n test -o express_oltp        
root      2177  0.0  0.0   9212  1044 pts/0    S+   13:03   0:00 grep --color=auto obd
```

从输出中可以看出，`obd cluster tenant create obcluster`表明系统正在创建`obcluster`集群(具体来说，是在名为 obcluster 的集群中创建一个名为 test 的租户，并使用 express_oltp 配置模板)，因此会出现obd lock或根本找不到obcluster的错误。

(操作那么急干嘛？容器还没初始化完成你就要开始进bash一顿操作了吗？)

2. Vscode Database插件连接数据库时，
    1. Host(win11)/WSL2 连接`172.17.0.2:2881`，提示`connect ETIMEDOUT`
        1. 猜测：172.17.0.2 是 Docker 内部网络的 IP 地址，主机无法直接访问 TODO
    2. WSL2下，Socat启动并监听2882端口，但连接时同样显示`connect ETIMEDOUT`
    3. 插件选择`127.0.0.1:2881`时，报错：`Parse Error: Expected HTTP/`
