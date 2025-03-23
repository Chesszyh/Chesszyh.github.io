# CodeTrace

## AI搜索集成说明

TODO: 集成AI问答功能，可以通过在搜索栏输入特定前缀激活不同的AI提供商：

- `@deepseek ` - 使用DeepSeek AI
- `@gemini ` - 使用Google Gemini
- `@openai ` - 使用OpenAI ChatGPT

### 在GitHub Pages部署AI功能

由于GitHub Pages是纯静态托管，无法直接运行服务器端代码或存储API密钥，因此需要使用外部服务来处理AI API调用：

#### 方案1：使用Cloudflare Workers (推荐)

1. 注册[Cloudflare Workers](https://workers.cloudflare.com/)账号
2. 创建新的Worker项目
3. 复制`static/api/ai/deepseek.js`的代码到Worker，并根据Cloudflare环境调整
4. 在Cloudflare Workers设置中添加环境变量`DEEPSEEK_API_KEY`、`GEMINI_API_KEY`和`OPENAI_API_KEY`
5. 在`search.html`文件中更新`apiEndpoint`变量为您的Cloudflare Worker URL

```javascript
// 修改search.html中的callAiApi函数
if (window.location.hostname.includes('github.io')) {
  apiEndpoint = `https://your-worker.your-username.workers.dev/api/${provider}`;
}
```

#### 方案2：使用其他无服务器函数服务

可以使用Netlify Functions、Vercel Edge Functions或AWS Lambda等服务。
