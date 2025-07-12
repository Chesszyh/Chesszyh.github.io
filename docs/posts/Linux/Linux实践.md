# Linux实践

标题取名“**Linux实践**”的原因：**实践**是一个**自顶向下**的过程，我在不断尝试Linux各种发行版、深入使用Linux系统的过程中，不断认识更多Linux的特性和命令行工具，但我不一定要知道这些工具的所有细节和原理。**实践**是简单的，什么命令忘了，`--help`/`man`/tab(zsh有补全脚本)/问AI都可以解决，但是**理解**是进阶的、复杂的，是一个**自底向上**的过程。

## Vim

一般只有两个用途：

1. 服务器上没别的可用了，我又不喜欢nano，那就vim吧
2. Windows下，在不打开IDE的情况下要创建代码文件时，可以直接地址栏`pwsh`然后`vim`启动。windows-vim我还配置了copilot，挺方便的。

### 复制粘贴

参考：https://blog.csdn.net/to_free/article/details/115187981

- vim内复制：`y`
- vim内粘贴：`p`
- 从系统剪切板粘贴：normal下`"*p`
- 复制到系统剪切板：normal下`"+y`

## Linux Command Line

### rsync(remote synchronization)

`rsync`：在本地系统之间或本地与远程系统之间高效地传输和同步文件及目录。

使用**增量传输算法**，只复制源和目标之间有差异的数据部分，从而提高传输效率。

AI总结：

---

`rsync` (remote synchronization) 是一个功能强大且用途广泛的命令行工具，用于在本地系统之间或本地与远程系统之间高效地传输和同步文件及目录。它以其增量传输算法而闻名，该算法只复制源和目标之间有差异的数据部分，从而大大减少了传输的数据量和时间。

**核心特性与优势：**

1.  **增量传输**：这是 `rsync` 最显著的特点。它通过比较源文件和目标文件的校验和（checksum）和修改时间，只传输实际发生变化的部分，而不是整个文件。
2.  **高效性**：由于增量传输，对于大型文件或大量文件的重复同步操作非常快速。
3.  **灵活性**：支持本地复制、本地到远程服务器（使用 SSH 或 RSH）、远程服务器到本地的同步。
4.  **多种选项**：提供了丰富的命令行选项，可以精细控制同步行为，如保留权限、时间戳、所有权、符号链接、排除特定文件等。
5.  **安全性**：可以通过 SSH 进行加密传输，确保数据在传输过程中的安全。
6.  **压缩**：可以在传输过程中压缩数据，以减少网络带宽占用。
7.  **断点续传**：如果传输中断，`rsync` 能够从中断的地方继续传输，而不是从头开始。

**基本语法：**

````bash
rsync [OPTIONS] SOURCE DESTINATION
````

*   `OPTIONS`: 控制 `rsync` 行为的各种选项。
*   `SOURCE`: 要复制或同步的源文件或目录。
*   `DESTINATION`: 文件或目录要被复制或同步到的目标位置。

**常用选项详解：**

*   `-a, --archive`：归档模式，相当于 `-rlptgoD` 的组合。这是一个非常常用的选项，用于保持文件的大部分属性：
    *   `-r, --recursive`：递归复制目录。
    *   `-l, --links`：复制符号链接本身，而不是链接指向的文件。
    *   `-p, --perms`：保留文件权限。
    *   `-t, --times`：保留文件修改时间。
    *   `-g, --group`：保留文件所属组。
    *   `-o, --owner`：保留文件所有者（仅限超级用户）。
    *   `-D`：等同于 `--devices --specials`，保留设备文件和特殊文件。
*   `-v, --verbose`：详细模式，输出更多关于正在进行的操作的信息。使用 `-vv` 或 `-vvv` 可以获得更详细的输出。
*   `-h, --human-readable`：以人类可读的格式输出数字（例如，KB, MB, GB）。
*   `--progress`：显示每个文件传输的进度。
*   `-P`：等同于 `--partial --progress`。`--partial` 允许保留部分传输的文件，以便在传输中断后可以续传。
*   `-n, --dry-run`：模拟运行。显示将要执行的操作，但实际上不进行任何更改。非常适合在实际执行前检查命令是否符合预期。
*   `--delete`：删除目标目录中存在但源目录中不存在的文件。这对于创建源目录的精确镜像非常有用。
*   `-z, --compress`：在传输过程中压缩文件数据。这可以减少网络流量，但会增加 CPU 负载。
*   `-e <COMMAND>`：指定用于远程连接的 shell。通常用于通过 SSH 连接：`-e ssh`。
*   `--exclude=PATTERN`：排除符合指定模式的文件或目录。
*   `--include=PATTERN`：包含符合指定模式的文件或目录（通常与 `--exclude` 结合使用以实现更复杂的过滤规则）。
*   `--update`：跳过目标位置中修改时间比源文件更新的文件。
*   `--existing`：只更新目标位置已经存在的文件，不创建新文件。

**源路径和目标路径的斜杠含义：**

*   **源路径末尾的斜杠 (`/`)**：
    *   如果 `SOURCE` 是一个目录且末尾有 `/` (例如 `source_dir/`)，`rsync` 会复制 `source_dir` 目录的 *内容* 到 `DESTINATION`。
    *   如果 `SOURCE` 是一个目录且末尾没有 `/` (例如 `source_dir`)，`rsync` 会将 `source_dir` 目录本身（包括目录名）复制到 `DESTINATION` 下。
*   **目标路径**：通常，如果目标路径不存在，`rsync` 会创建它。

**示例：**

1.  **本地复制目录内容（类似 `cp -r`）：**
    ````bash
    rsync -avh source_directory/ destination_directory/
    ````
    这将把 `source_directory` 里面的所有内容复制到 `destination_directory`。

2.  **本地复制整个目录（包括目录本身）：**
    ````bash
    rsync -avh source_directory destination_parent_directory/
    ````
    这会在 `destination_parent_directory` 下创建一个名为 `source_directory` 的目录，并将源目录的内容复制进去。

3.  **将本地目录同步到远程服务器：**
    ````bash
    rsync -avzhe ssh /path/to/local/source_dir/ user@remote_host:/path/to/remote/destination_dir/
    ````
    *   `-z`：启用压缩。
    *   `-e ssh`：通过 SSH 连接。

4.  **将远程服务器目录同步到本地：**
    ````bash
    rsync -avzhe ssh user@remote_host:/path/to/remote/source_dir/ /path/to/local/destination_dir/
    ````

5.  **创建本地目录的镜像（删除目标中多余的文件）：**
    ````bash
    rsync -avh --delete source_directory/ backup_directory/
    ````

6.  **显示进度并进行模拟运行：**
    ````bash
    rsync -avhn --progress source_directory/ destination_directory/
    ````

7.  **排除特定文件或目录：**
    ````bash
    rsync -avh --exclude='*.log' --exclude='temp_folder/' source_directory/ destination_directory/
    ````

**重要注意事项：**

*   **仔细检查路径**：特别是源路径末尾的斜杠，它会显著改变 `rsync` 的行为。
*   **使用 `--dry-run`**：在执行可能具有破坏性（如 `--delete`）的命令之前，强烈建议先使用 `--dry-run` 选项进行测试。
*   **权限**：当使用 `-o` (owner) 和 `-g` (group) 选项时，通常需要超级用户权限（`sudo`）才能在目标系统上正确设置所有者和组。
*   **SSH 密钥**：为了避免在每次与远程服务器同步时都输入密码，建议配置 SSH 密钥认证。

`rsync` 是一个非常强大的工具，掌握它的常用选项和行为对于系统管理员、开发人员以及任何需要进行文件同步和备份的人来说都非常有价值。建议通过阅读其 `man` 手册页 (`man rsync`) 来了解更多高级选项和用法。

### time

大多数 Unix-like 系统通常有两个 `time` 命令：一个是当前shell的内置命令，输出相对简单；另一个是GNU time，即`/usr/bin/time`。`PATH`设置正确时，可通过`\time`强制调用外部的GNU time命令。

`time`命令输出：

- `real`：实际经过的时间（wall clock time），包括命令实际运行的时间、等待 I/O 操作（如读写磁盘、网络请求）的时间，以及被操作系统其他进程抢占 CPU 的时间，等等。
- `user`：用户态 CPU 时间，是程序自身代码（不包括内核代码）消耗的 CPU 周期，比如进行计算、数据处理等。
- `sys`：内核态 CPU 时间，当程序需要操作系统提供的服务时（例如进行系统调用，如打开文件、分配内存、网络通信等），切换到内核态后消耗的 CPU 时间。

- 比较：
    - `real` >> `user` + `sys`：系统高负载，或程序长时间等待IO操作。
    - `real` ≈ `user` + `sys`：CPU计算密集型任务。
    - `real` < `user` + `sys`：可能是多核并行计算。
- 输出格式控制：利用环境变量：`TIMEFORMAT=$'Real: %Rs\nUser: %Us\nSys: %Ss'`

**使用示例**：

```bash
\time -v ls -lR /usr/include > /dev/null # 基本使用：将 ls 的输出重定向到 /dev/null 以便只关注 time 的输出
\time -f "Command: %C\nReal: %E\nUser: %U\nSys: %S\nCPU: %P\nMax RSS: %M KB" sleep 2 # 自定义输出格式
\time -o benchmark.log -a -f "%C took %E" ./my_script.sh # 将输出追加到 benchmark.log 文件中
```