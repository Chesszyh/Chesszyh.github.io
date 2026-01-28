# Better Vibe Coding

> 2025年，基础模型没有太大突破，各大厂商都开始下场AI Agents应用了。IDE方向，几乎已经没有不能集成AI的了：Vscode, Cursor, Windsurf, Kiro(Amazon), Trae, Qoder(阿里)，我拥有github学生会员并且用vscode也用习惯了，就懒得换别的了，顶多尝下鲜。我还是挺希望能看到基础模型架构或能力有突破的，目前的llm，整多少花活，似乎都不是那么的“智能”。

## CLI Agent

日常我真正用的多的，其实只有这两个：

- claude-code
- codex

Claude老是封号，所以需要一些中转api或路由来辅助使用。

其他能用的：

- [gemini-cli](https://github.com/google-gemini/gemini-cli)：主要是免费，量大管饱，但是能力有限
- [warp](https://www.warp.dev/)：交互体验很好，实际写代码我用的较少

最新探索的：

- [opencode](https://github.com/anomalyco/opencode)：社区开源、带图形化界面的CLI Agent
    - 支持非常多种模型，而且有免费额度，但是我总遇到启动界面卡死问题
    - [oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode)：opencode的插件管理器
        - [X上的一个推文](https://x.com/RookieRicardoR/status/2007450352350834837?s=20)
- [amp](https://ampcode.com/)
    - 据说有奇效，我也不知道

不怎么能用的：

- [copilot](https://github.com/features/copilot/cli): Github的，感觉功能非常单薄

我下载过几乎没用过的：

- cursor-agent
- iflow：似乎有Deepseek之类模型的免费
- qwen

## Proxy 

- [CLI Proxy整合](https://github.com/router-for-me/CLIProxyAPI)
    - 这个似乎用的人比较多
- [Claude-code Router](https://github.com/musistudio/claude-code-router)：可自定义api，中转其他模型
- [Copilot API](https://github.com/ericc-ch/copilot-api)：可调用github copilot的api，充分利用每月300次高级模型额度和无限制的gpt-5-mini, gpt-4.1等额度。
- [Antigravity API](https://github.com/ink1ing/anti-api)
- [Antigravity 账号管理](https://github.com/lbjlaq/Antigravity-Manager)

## 不负责任的Vibe Coding

最好通过只读用户登录，或者在容器中运行，以防止意外的数据丢失或泄露。

```bash
claude --dangerously-skip-permissions

codex --sandbox workspace-write --ask-for-approval never

gemini -m gemini-3-flash-preview  --yolo
```

## MCP(Model Context Protocol)

### 参考资源

- [MCP-Anthropic](https://www.anthropic.com/news/model-context-protocol)
- [MCP-for-beginners](https://github.com/microsoft/mcp-for-beginners)
- [Doc](https://modelcontextprotocol.io/docs)
- Github：Anthropic/MCP官方账号

可以期待一下Docker对MCP更好的集成。

---

> 2026-01-03更新

现在MCP好像都有点过时了？`skills`越来越流行。我也搞不太懂，日常没怎么用到过，vibe-coding还是太少了。
