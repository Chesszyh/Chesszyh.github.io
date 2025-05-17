# Miniob

[Gemini Research](https://docs.google.com/document/d/1OFiJKDhV0Q0xuUmoHbJqgLFT8ID5vLwQuzUBDWf8xOs/edit?tab=t.0)

[Miniob架构文档](https://oceanbase.github.io/miniob/design/miniob-architecture/#_3)

[miniob](https://hub.docker.com/r/oceanbase/miniob) 是 OceanBase 与华中科技大学联合开发的、面向零基础数据库内核知识同学的一门数据库实现入门教程实践工具，设计目标是让不熟悉数据库设计和实现的同学能够快速的了解与深入学习数据库内核。

## Getting Started

### Run Miniob on Docker

```shell
# 1. Docker下载官方miniob镜像
# --privileged: 获取root权限
# -v: 挂载本地目录到容器内(共享目录，修改实时同步)
docker run -d --privileged --name=miniob oceanbase/miniob

# 2. 进入容器内部，编译安装
docker exec -it miniob bash
git clone https://github.com/oceanbase/miniob.git
cd miniob
bash build.sh --make -j4 

# 3. 编译后，进入build目录，运行
cd build
# 以后修改数据库后，执行：
# make clean
# make -j32
./bin/observer -s miniob.sock -f ../etc/observer.ini & # 在后台启动服务
# kill -9 $(pgrep observer) # 关闭服务

# 4. 连接数据库
./bin/obclient -s miniob.sock
```

### Build Miniob from Source

参考https://oceanbase.github.io/miniob/how_to_build/#2。

```shell
git clone https://github.com/oceanbase/miniob/
cd miniob
bash build.sh init # 136.92s user 29.97s system 34% cpu 8:09.70 total
bash build.sh -j32 # 编译，32核WSL2-Ubuntu原生文件夹，需要351s：351.20s user 39.44s system 76% cpu 8:32.50 total
```

## Log

- 5.7
    - Sqlmap：已删除，暂时不涉及到sql注入等知识
    - neon, ragflow: 已经移到wsl-`/root/Project`下，提高性能
    - 学习GDB调试miniob项目
- 5.10 
    - 用AI把报告水完了，最近事多，如果有时间/作业要更深层次的理解的话，再精读代码吧

## 项目外部库依赖

### stdarg.h

- `stdarg.h`：C标准库，可变参数列表的处理，类似python的`*args`和`**kwargs`。

    *   相关的宏和类型有：
        *   `va_list`: 用于声明一个指向参数列表的变量。
        *   `va_start`: 初始化 `va_list` 变量，使其指向第一个可变参数。
        *   `vsnprintf`: 用于根据格式字符串和参数列表将格式化的输出写入字符数组，并且它是安全的，可以防止缓冲区溢出。
        *   `va_end`: 清理 `va_list` 变量。

一个使用示例：

```c
const int buffer_size = 4096;
char     *str         = new char[buffer_size];

va_list ap;
va_start(ap, fmt);  // fmt格式串由调用者提供，格式检查于外部完成 (?)
vsnprintf(str, buffer_size, fmt, ap);   // 将fmt格式化的字符串写入str中
va_end(ap);
```

## SQL语句

作业要求：对 miniob 源码进行阅读，主要选取一个功能（如 create table、insert、delete 等）进行分析理解，做简要报告。

SQL -> SQL解析器 -> 生成AST节点(包含创建表所需的所有信息) -> 

### SELECT语句

- 默认表：`Tables_in_SYS`;
    - `select * from Tables_in_SYS;` --> FAILURE 为什么

## 代码解读

### 语法解析层

- `observer/sql/parser/parse_defs.h`：定义了SQL语句的结构体，包括`CreateTableSqlNode`、`DropTableSqlNode`等。
     首先引入自定义的`string`, `vector`, `memory`等头文件(包含自定义函数：C++库函数的封装)，然后引入`value.h`，应该是数据库的值类型定义。
- `observer/sql/stmt/create_table_stmt.h`：`DropTableStmt`等处理SQL语句。

### SQL执行

- `observer/storage/default/default_handler.cpp`：在`DefauleHandler`中实现SQL语句的执行。

#### Drop Table



### 日志、调试输出

- `observer/event/sql_debug.h`：

    - `sql_debug`函数逻辑：
        - 会话：局部线程/全局管理机制
        - 如果有会话，再从会话中获取当前线程的`SessionEvent`，否则返回
        - 准备缓冲区(固定4096)并格式化字符串

## Idea

1. 正则表达式学习、如何正确解析sql语句？
2. 数据库一般都有`help`命令，以后用之前先查看一下该数据库的方言，省得浪费时间
3. 类似python `kanren`的逻辑式编程：`select * from table where`后条件的解析
4. SQL对语法错误的提示，为什么如此不清晰？(Syntax error near token `xxx`, 我怎么知道具体哪错了？)