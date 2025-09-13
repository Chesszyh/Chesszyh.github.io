# Github actions

## 限额与配置

> 虽然很难用超了，但我刚开始学CI/CD，尝试分发Electron全平台打包的可执行程序的时候，2个项目2天之内用掉了1405min额度和0.8GB存储，很多都是重复的无用功……

根据[GitHub文档](https://docs.github.com/zh/billing/concepts/product-billing/github-actions#minute-multipliers)，个人用户免费使用额度：

- Free：500MB, 2000mins/month
- Pro：1GB, 3000mins/month

其中，在 GitHub 托管的 Windows 和 macOS 运行器上运行的作业消耗分钟数的速率是 Linux 运行器上作业消耗分钟数的速率的 **2 倍和 10 倍**。

[Billing](https://github.com/settings/billing)页面可以查看使用情况，使用超额并且没有添加支付方式时，actions将无法使用，直到下个月初重置额度。

关于三大系统的官方 Runner 平台：

- Linux: ubuntu-24.04, ubuntu-22.04, ubuntu-20.04
- Windows: windows-latest (windows-server-2022), windows-2022, windows-2019
  - 支持 PowerShell, Visual Studio, .NET, MSVC, MinGW 等工具
- macOS: macos-latest (macos-14-sonoma), macos-13-ventura, macos-12-monterey
  - 支持 Xcode, Swift, CocoaPods, Homebrew, Ruby 等工具
  - 启动速度最慢，队列经常要排队

关于版本选择：如果项目对编译环境要求严格，推荐写死版本号（比如 ubuntu-22.04 而不是 ubuntu-latest），因为latest可能会随着Github更新而改变，导致不可预期的问题。

<details>
<summary> 该界面所有服务的免费额度 </summary>
<table>
<thead>
<tr>
<th>功能/产品</th>
<th>GitHub Pro 含免费额度 / 包含额度</th>
<th>备注改动 / 限制</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong>GitHub Actions</strong></td>
<td>每月 <strong>3,000 分钟（minutes）</strong> + <strong>1 GB 工件存储（artifact storage）</strong>。</td>
<td>这是 GitHub-hosted runner 的额度；超出后按费率计费。</td>
</tr>
<tr>
<td><strong>GitHub Codespaces</strong></td>
<td>每月 <strong>180 小时</strong> 的计算时间 + <strong>20 GB-月</strong> 的存储空间。</td>
<td>这是个人账户 Pro 的额度。</td>
</tr>
<tr>
<td><strong>GitHub Copilot</strong></td>
<td>Pro 计划（个人）包含：无限代码补全（code completions） + <strong>300 premium requests / 月</strong>。</td>
<td>“Premium requests” 是指使用特定模型 /高级特性（例如在 Chat 模式、用 premium AI 模型等）会用这个额度。超过后可能要额外付费。</td>
</tr>
<tr>
<td><strong>Git LFS (Large File Storage)</strong></td>
<td>Pro 与 Free 在 LFS 上的存储和带宽额度 <strong>相同</strong>：每月 <strong>10 GiB 存储 + 10 GiB 带宽</strong>。</td>
<td>对比 Team /企业计划，该额度更大。</td>
</tr>
<tr>
<td><strong>GitHub Packages (私有仓库包 + 传输)</strong></td>
<td>Pro 计划：<strong>2 GB 存储</strong> + <strong>10 GB 数据传输（data transfer）</strong>／月。</td>
<td>公共包（public packages）相关存储与下载通常免费。私有仓库的包和下载会计入私有额度。</td>
</tr>
<tr>
<td><strong>GitHub Models / Playground / AI 模型原型</strong></td>
<td>GitHub Models 提供 <em>免费原型试验(prototyping)</em> 的能力；Playground 可以免费使用、试验模型和 prompt。Rate limits (速率限制) 存在。</td>
<td>若超出免费 /试用限额或要投入生产环境使用、或使用“付费 / BYOK（Bring Your Own Key）”路径，则会计费。</td>
</tr>
</tbody>
</table>
</details>

## 基本概念

- `Runner`：执行工作流的服务器，可以是 GitHub 提供的虚拟机，也可以是自托管服务器
  - `Workflow`：YAML 文件，定义自动化任务
    - `Job`：workflow 中的一个并行/串行单位，可用`needs`指定依赖关系
      - `Step`：job 中的一个顺序执行单元
        - `Action`：可复用的功能模块（JavaScript、Docker 或 composite），由 step 用 `run` 或 `uses`(可复用) 调用
          - `script`：执行的脚本

### 变量

- `env`：非敏感信息变量，在输出中明文显示。`Workflow`、`Job`、`Step` 均可定义
  - 单工作流直接在YAML文件中定义，多工作流可在仓库设置的 `Secrets and variables` 中定义
  - `env`定义可以位于使用`env`的脚本之后，只要确保与脚本在同一作用域即可
  - 常用环境变量：
    - `runner.os`

- `var`：引用在仓库/组织/环境设置里配置的变量
- `secret`：用于保护敏感信息的变量

### 上下文

- `context`：在作业尚未运行前需要做决策或动态构建 workflow（比如 if、runs-on、matrix）时使用

## 效率提升

### 共享数据

- `actions/upload-artifact`：上传文件供后续 job 使用
- `actions/download-artifact`：下载之前 job 产出的文件

### 缓存

- `actions/cache`：缓存依赖包等，减少重复下载
  - `key`：缓存键，必须唯一且不可变
  - `path`：缓存路径
  - `restore-keys`：可选，指定多个备选键，按顺序匹配。设置时可由长到短。

示例：在 package-lock.json 文件中的包更改时，或运行器的操作系统更改时，创建一个新的缓存。`hashFiles` 会基于文件内容，计算`hash "package-lock.json"`生成哈希值。

手动配置缓存：

```yaml
name: Caching with npm
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Cache node modules
        id: cache-npm
        uses: actions/cache@v4
        env:
          cache-name: cache-node-modules
        with:
          # npm cache files are stored in `~/.npm` on Linux/macOS
          path: ~/.npm
          key: ${{ runner.os }}-build-${{ env.cache-name }}-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-build-${{ env.cache-name }}-
            ${{ runner.os }}-build-
            ${{ runner.os }}-

      - if: ${{ steps.cache-npm.outputs.cache-hit != 'true' }}
        name: List the state of node modules
        continue-on-error: true
        run: npm list
```

针对常见包管理器（如 npm、pip、maven 等），Github提供自动安装和缓存依赖的 Actions。通过`setup-<tool>` Action 的 `cache` 参数启用。

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 18
          cache: 'npm'   # 自动缓存 npm 依赖
      - run: npm ci
      - run: npm test
```

## CI/CD：持续集成/连续部署

> 持续集成 (CI) 是一种需要频繁提交代码到共享仓库的软件实践。 频繁提交代码能较早检测到错误，减少在查找错误来源时开发者需要调试的代码量。 频繁的代码更新也更便于从软件开发团队的不同成员合并更改。 这对开发者非常有益，他们可以将更多时间用于编写代码，而减少在调试错误或解决合并冲突上所花的时间。

> 持续部署 (CD) 是使用自动化发布和部署软件更新的做法。 作为典型 CD 过程的一部分，代码在部署之前会自动构建并测试。

## 自托管服务

### [act](https://github.com/nektos/act)

`act` 是一个可以在本地运行 GitHub Actions 的工具，使用 Docker 模拟 GitHub 的运行环境。它可以帮助开发者在本地测试工作流，避免频繁消耗 GitHub Actions 的免费额度。

需要注意，`act`无法模拟Windows/macOS，也并不能完全模拟Github runner的行为(因为基于Docker)。

### 自托管 runner

可以将 GitHub Actions 的 runner 部署在自有服务器上，避免使用 GitHub 提供的虚拟机，节省资源和时间开销，也方便手动登录服务器进行调试。安装方法可参考[官方文档](https://docs.github.com/zh/actions/how-tos/manage-runners/self-hosted-runners/add-runners)，非常简单。

注意，self-hosted runner 会主动连接 GitHub 的 Actions 服务端，然后轮询自己有没有任务。也就是说，**self-hosted runner 不需要开放公网端口**（我预想中是由Github分发给runner任务，runner需要公网访问权限），只要能访问 GitHub 就行。

安全方面，要使用非 root 用户运行 runner 服务（root用户，脚本会阻止安装），防止恶意工作流取得系统完全控制权限。

```bash
# 创建专用普通用户并设置 runner 目录
sudo useradd -m -s /bin/bash actions
sudo mkdir -p /home/actions/actions-runner
sudo chown -R actions:actions /home/actions
```

可设置systemd服务自动启动：

```ini
[Unit]
Description=GitHub Actions Runner
After=network.target

[Service]
User=actions
WorkingDirectory=/home/actions/actions-runner
ExecStart=/home/actions/actions-runner/run.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

### 自托管Windows/Mac解决方案

Github Actions的自托管runner，Win/Mac都是比较耗额度的，尤其是Mac。正好我还有macmini，所以将本地macmini作为自托管Mac runner是非常划算的方案。而Windows，我打算采用[Windows-docker](https://github.com/dockur/windows)提供的轻量化Win虚拟机方案。

### act or self-hosted runner?

目前我觉得self-hosted runner更好，主要是因为GFW。

act的话，我不仅要给docker配置代理/换源，忍受奇慢无比的代理网速，还要跑自己的流量，act本身可能还有不兼容github actions的bug。

self-hosted runner的话，我可以把它部署在国外的VPS上，网速超级快(估计有上百兆/s)，而且云服务器闲着也是闲着，闲着不干也得交钱。

目前使用的是Digital Ocean提供给学生的$200免费额度，每月8美元的1c1g VPS。justhost提供$0.99/月的1c512m的VPS，我暂时还没试过，看起来也是很划算了。

## IDEA

我想创建一个Actions仓库，专门存放大量自己的**娱乐性质**的actions。我想让这些actions支持原子化管理和依赖管理，比如："diary"只在我的私有仓库"https://github.com/Chesszyh/Diary"有推送的时候才触发。

不过我很快认识到，这似乎是个伪需求，能用actions做的，我自己联网的电脑也能做，还能做的更方便更快。

所以还是以后用到electron全平台打包分发之类的需求时再说吧。