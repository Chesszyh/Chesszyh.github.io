# AWS Lambda AI API 部署指南

此目录包含为GitHub Pages网站提供AI功能的AWS Lambda函数代码。

## 部署步骤

### 1. 创建Lambda函数

1. 登录AWS控制台并导航至Lambda服务
2. 点击"创建函数"
3. 选择"从头开始创作"
4. 命名您的函数，例如"ai-api-handler"
5. 运行时选择"Node.js 18.x"
6. 点击"创建函数"

### 2. 上传代码

1. 将`ai-handler.js`中的代码复制到Lambda函数的代码编辑器中
2. 或者创建部署包（zip文件）并上传

### 3. 配置环境变量

在Lambda函数的"配置"选项卡下，添加以下环境变量：

- `DEEPSEEK_API_KEY`: 您的DeepSeek API密钥
- `GEMINI_API_KEY`: 您的Google Gemini API密钥
- `OPENAI_API_KEY`: 您的OpenAI API密钥

### 4. 设置API Gateway

1. 在Lambda函数页面，选择"添加触发器"
2. 选择"API Gateway"
3. 创建新的API或使用现有API
4. 选择"REST API"类型
5. 安全选择"开放"（或根据需要设置API密钥）
6. 点击"添加"

### 5. 配置CORS（跨源资源共享）

在API Gateway控制台中：

1. 选择您的API
2. 选择资源和方法
3. 点击"操作"并选择"启用CORS"
4. 输入以下设置：
   - Access-Control-Allow-Origin: `https://您的网站域名`（或`*`用于测试）
   - Access-Control-Allow-Headers: `Content-Type,X-Amz-Date,Authorization`
   - Access-Control-Allow-Methods: `OPTIONS,POST`
5. 点击"启用CORS并替换现有CORS标头"

### 6. 部署API

1. 点击"操作"并选择"部署API"
2. 选择部署阶段或创建新阶段
3. 点击"部署"

### 7. 获取API URL

部署后，您将获得API URL，格式如下：
```
https://your-api-id.execute-api.your-region.amazonaws.com/stage/ai/{provider}
```

### 8. 更新网站配置

在`search.html`文件中，找到以下代码并替换为您的实际API URL：

```javascript
// 如果是GitHub Pages环境，使用AWS API Gateway
if (window.location.hostname.includes("github.io")) {
  apiEndpoint = `https://your-api-id.execute-api.your-region.amazonaws.com/stage/ai/${provider}`;
}
```

## 测试API

您可以使用以下curl命令测试API：

```bash
curl -X POST \
  https://your-api-id.execute-api.your-region.amazonaws.com/stage/ai/deepseek \
  -H 'Content-Type: application/json' \
  -d '{"provider": "deepseek", "question": "你好，世界！"}'
```

## 监控与日志

在Lambda和API Gateway控制台中查看日志和监控指标，以便排除故障和优化性能。
