// 这是一个简单的示例后端处理器，实际部署时需要替换为您的服务器端代码
// 此文件应该放在可执行服务器端代码的位置，根据您的托管环境可能需要调整

export async function onRequest(context) {
    // 从环境变量中获取API密钥
    const apiKey = context.env.DEEPSEEK_API_KEY;

    if (!apiKey) {
        return new Response(JSON.stringify({
            error: "API key not configured"
        }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' }
        });
    }

    try {
        // 解析请求体
        const { question } = await context.request.json();

        if (!question) {
            return new Response(JSON.stringify({
                error: "Question is required"
            }), {
                status: 400,
                headers: { 'Content-Type': 'application/json' }
            });
        }

        // 调用DeepSeek API
        const response = await fetch('https://api.deepseek.com/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`
            },
            body: JSON.stringify({
                model: 'deepseek-chat',
                messages: [
                    { role: 'user', content: question }
                ],
                temperature: 0.7,
                max_tokens: 2000
            })
        });

        const data = await response.json();

        // 检查API响应
        if (data.error) {
            return new Response(JSON.stringify({
                error: data.error.message || "DeepSeek API error"
            }), {
                status: 500,
                headers: { 'Content-Type': 'application/json' }
            });
        }

        // 返回回答
        return new Response(JSON.stringify({
            answer: data.choices[0].message.content
        }), {
            headers: { 'Content-Type': 'application/json' }
        });

    } catch (error) {
        return new Response(JSON.stringify({
            error: error.message || "Internal server error"
        }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' }
        });
    }
}
