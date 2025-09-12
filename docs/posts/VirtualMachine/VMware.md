# VMWare

我的主力机器是Fedora 42。

VMware作为商业闭源软件，在Fedora比较激进的更新策略下经常出现问题，比如`vmnet`和`vmmon`安装不上。这次遇到的报错是VM
17.6.4与内核6.16.4不兼容。

通用的解决方案是参考[Patches Repo](https://github.com/mkubecek/vmware-host-modules)中的不同分支和Issue区的最新社区补丁。本次参考的补丁是2周前非常活跃的、有20个comments的[Issue](https://github.com/mkubecek/vmware-host-modules/issues/319)补丁：https://github.com/arizvisa/mkubecek.vmware-host-modules. 该补丁也有一点小问题，是`VMMON`的版本号不对，在`vmnet-only/include/iocontrols.h`中修改416为417即可。然后执行以下命令（也是通用的）：

```bash
cd vmware-host-modules
make # NOTE 我们只需要make的中间产物，sudo make install似乎也会出现问题
sudo cp vmmon.o /lib/modules/$KERNEL_VERSION/misc/vmmon.ko
sudo cp vmnet.o /lib/modules/$KERNEL_VERSION/misc/vmnet.ko
sudo depmod -a # 更新模块依赖
sudo systemctl restart vmware.service
```

重新启动Vmware即可。

