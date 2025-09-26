# 解决 Vscode 中 clangd 找不到标准库头文件的问题

查找标准库头文件路径：

```bash
echo | g++ -E -x c++ - -v
```

输出中可能包括：

```plaintext
#include "..." 搜索从这里开始：
#include <...> 搜索从这里开始：
 /usr/lib/gcc/x86_64-redhat-linux/15/../../../../include/c++/15
 /usr/lib/gcc/x86_64-redhat-linux/15/../../../../include/c++/15/x86_64-redhat-linux
 /usr/lib/gcc/x86_64-redhat-linux/15/../../../../include/c++/15/backward
 /usr/lib/gcc/x86_64-redhat-linux/15/include
 /usr/local/include
 /usr/include
搜索列表结束。
```

在vscode全局配置的参数`clangd.fallbackFlags`下，添加这些路径即可。

在项目内，更好的解决方案是生成`compile_commands.json`文件：

```bash
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
```

这样 clangd 能自动获取所有编译参数和 include 路径。

<details>
<summary>My VScode Settings.json (clangd part)</summary>

```json
{
    // Last sync: 2025-09-26
    // ------------- Clangd settings START -------------------
    // Clangd 运行参数(终端输入 clangd --help-list-hidden 可查看更多)
    "clangd.path": "/home/chesszyh/.config/Code/User/globalStorage/llvm-vs-code-extensions.vscode-clangd/install/20.1.8/clangd_20.1.8/bin/clangd",
    "clangd.arguments": [
        "--all-scopes-completion", // 全局补全(补全建议会给出在当前作用域不可见的索引,插入后自动补充作用域标识符),例如在main()中直接写cout,即使没有`#include <iostream>`,也会给出`std::cout`的建议,配合"--header-insertion=iwyu",还可自动插入缺失的头文件
        "--background-index", // 后台分析并保存索引文件
        "--clang-tidy", // 启用 Clang-Tidy 以提供「静态检查」
        "--clang-tidy-checks=performance-*, bugprone-*, misc-*, google-*, modernize-*, readability-*, portability-*",
        "--compile-commands-dir=${workspaceFolder}/.vscode", // 编译数据库(compile_commands.json 文件)的目录位置
        "--completion-parse=auto", // 当 clangd 准备就绪时，用它来分析建议
        "--completion-style=detailed", // 建议风格：打包(重载函数只会给出一个建议);还可以设置为 detailed
        "--query-driver=/usr/bin/g++", // MAC 上需要设定 clang 编译器的路径，也可以是 /usr/local/opt/llvm/bin/clang++. NOTE: 原来是clang++-18
        // 启用配置文件(YAML格式)
        "--enable-config",
        "--fallback-style=Webkit", // 默认格式化风格: 在没找到 .clang-format 文件时采用,可用的有 LLVM, Google, Chromium, Mozilla, Webkit, Microsoft, GNU
        "--function-arg-placeholders=true", // 补全函数时，将会给参数提供占位符，键入后按 Tab 可以切换到下一占位符，乃至函数末
        "--header-insertion-decorators", // 输入建议中，已包含头文件的项与还未包含头文件的项会以圆点加以区分
        "--header-insertion=iwyu", // 插入建议时自动引入头文件 iwyu
        "--include-cleaner-stdlib", // 为标准库头文件启用清理功能(不成熟!!!)
        "--log=verbose", // 让 Clangd 生成更详细的日志
        "--pch-storage=memory", // pch 优化的位置(Memory 或 Disk,前者会增加内存开销，但会提升性能)
        "--pretty", // 输出的 JSON 文件更美观
        "--ranking-model=decision_forest", // 建议的排序方案：hueristics (启发式), decision_forest (决策树)
        "-j=12", // 同时开启的任务数量
    ],
    // 找不到编译数据库(compile_flags.json 文件)时使用的编译器选项,这样的缺陷是不能直接索引同一项目的不同文件,只能分析系统头文件、当前文件和被include的文件
    "clangd.fallbackFlags": [
        "-pedantic",
        "-Wall",
        "-Wextra",
        "-Wcast-align",
        "-Wdouble-promotion",
        "-Wformat=2",
        "-Wimplicit-fallthrough",
        "-Wmisleading-indentation",
        "-Wnon-virtual-dtor",
        "-Wnull-dereference",
        "-Wold-style-cast",
        "-Woverloaded-virtual",
        "-Wpedantic",
        "-Wshadow",
        "-Wunused",
        "-pthread",
        "-fuse-ld=lld",
        "-fsanitize=address",
        "-fsanitize=undefined",
        // "-stdlib=libc++", // 使用g++时，需要注释掉此行
        "-I/usr/lib/gcc/x86_64-redhat-linux/15/../../../../include/c++/15",
        "-I/usr/lib/gcc/x86_64-redhat-linux/15/../../../../include/c++/15/x86_64-redhat-linux",
        "-I/usr/lib/gcc/x86_64-redhat-linux/15/../../../../include/c++/15/backward",
        "-I/usr/lib/gcc/x86_64-redhat-linux/15/include",
        "-I/usr/local/include",
        "-I/usr/include"
    ],
    "clangd.checkUpdates": true, // 自动检测 clangd 更新
    "clangd.onConfigChanged": "restart", // 重启 clangd 时重载配置,具体方法: F1 + Fn 打开命令面板，然后搜索“clangd: restart"
    "clangd.serverCompletionRanking": true, // 借助网上的信息排序建议
    "clangd.detectExtensionConflicts": true, // 当其它拓展与 clangd 冲突时警告并建议禁用
    // --------------- Clangd settings END -------------------
}
```
</details>