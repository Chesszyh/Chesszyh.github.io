# Mkdocs + Github Pages

本项目包含了多个中英文版本的Wiki文档，每个文件夹（除了`.`开头的隐藏文件夹）下的内容结构类似，如下所示(以`lc0`为例)：

```bash
lc0_deepwiki
├── 1-lc0-overview.md
├── 2-building-and-installation
│   ├── 2.1-build-system-architecture.md
│   ├── 2.2-linux-and-macos-build-process.md
├── 2-building-and-installation.md
└── zh
    ├── 1-lc0-overview.md
    ├── 2-building-and-installation
    │   ├── 2.1-build-system-architecture.md
    │   ├── 2.2-linux-and-macos-build-process.md
    ├── 2-building-and-installation.md
...
```

其中，`zh`文件夹下的内容是对应上级目录的中文翻译版本，结构完全一致。注意，`1-lc0-overview.md`表示第一章仅有这一个概述文件，不包含文件夹；`2-building-and-installation.md`和`2-building-and-installation/`表示第二章既有一个概述文件，也有多个子章节文件。在Wiki侧边栏中，章节的排序应与文件名中的数字顺序一致，即使没有子章节，也应当出现在侧边栏和页面中。

要求：

1. 加入mermaid渲染支持
2. 抑制一切警告，加快编译速度
3. 每个章节数字应根据从小到大顺序，对应Wiki侧边栏中从上到下的排序。
4. 能一键切换当前文档中英文，这样也为了以后i18n更多语言的加入着想。

现在，我需要你为所有这些Wiki文档生成一个统一的`mkdocs.yml`配置文件，支持中英文切换，然后部署到GitHub Pages，方便进行托管和访问。任务完成后请运行`mkdocs build`或`mkdocs serve`进行本地预览，确保一切正常。