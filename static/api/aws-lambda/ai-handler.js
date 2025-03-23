/**
 * AWS Lambda函数处理AI API请求
 */

// 导入所需库
const https = require('https');

// AI提供商配置
const providers = {
    deepseek: {
        endpoint: 'api.deepseek.com',
        path: '/v1/chat/completions',
        model: 'deepseek-chat',
        apiKeyEnv: 'DEEPSEEK_API_KEY'
    },
    gemini: {
        endpoint: 'generativelanguage.googleapis.com',
        path: '/v1beta/models/gemini-pro:generateContent',
        apiKeyEnv: 'GEMINI_API_KEY'
    },
    openai: {
        endpoint: 'api.openai.com',
        path: '/v1/chat/completions',
        model: 'gpt-3.5-turbo',
        apiKeyEnv: 'OPENAI_API_KEY'
    }
};

/**
 * Lambda处理函数
 */
exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event));

    try {
        // 允许CORS
        const headers = {
            'Access-Control-Allow-Origin': '*', // 或指定您的域名
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'OPTIONS,POST'
        };

        // 处理预检请求
        if (event.httpMethod === 'OPTIONS') {
            return {
                statusCode: 200,
                headers,
                body: JSON.stringify({ status: 'ok' })
            };
        }

        // 解析请求体
        let body;
        try {
            body = JSON.parse(event.body);
        } catch (e) {
            return errorResponse('无效的请求体', 400, headers);
        }

        const { provider, question } = body;

        if (!provider || !question) {
            return errorResponse('缺少提供商或问题参数', 400, headers);
        }

        // 检查提供商是否受支持
        if (!providers[provider]) {
            return errorResponse(`不支持的AI提供商: ${provider}`, 400, headers);
        }

        // 获取API密钥
        const apiKey = process.env[providers[provider].apiKeyEnv];
        if (!apiKey) {
            return errorResponse(`${provider} API密钥未配置`, 500, headers);
        }

        // 调用相应的AI API
        const answer = await callAiApi(provider, question, apiKey);

        // 返回成功响应
        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({ answer })
        };

    } catch (error) {
        console.error('Error:', error);
        return errorResponse(error.message, 500);
    }
};

/**
 * 调用AI API
 */
async function callAiApi(provider, question, apiKey) {
    const config = providers[provider];

    // 准备请求数据
    let requestData;
    let reqHeaders = {
        'Content-Type': 'application/json'
    };

    // 不同提供商的数据格式不同
    switch (provider) {
        case 'deepseek':
            reqHeaders['Authorization'] = `Bearer ${apiKey}`;
            requestData = JSON.stringify({
                model: config.model,
                messages: [{ role: 'user', content: question }],
                temperature: 0.7,
                max_tokens: 2000
            });
            break;

        case 'gemini':
            // Gemini使用URL参数传递API密钥
            config.path = `${config.path}?key=${apiKey}`;
            requestData = JSON.stringify({
                contents: [{ parts: [{ text: question }] }],
                generationConfig: {
                    temperature: 0.7,
                    maxOutputTokens: 2048
                }
            });
            break;

        case 'openai':
            reqHeaders['Authorization'] = `Bearer ${apiKey}`;
            requestData = JSON.stringify({
                model: config.model,
                messages: [{ role: 'user', content: question }],
                temperature: 0.7,
                max_tokens: 2000
            });
            break;

        default:
            throw new Error(`未知的提供商: ${provider}`);
    }

    // 发送HTTP请求
    return new Promise((resolve, reject) => {
        const options = {
            hostname: config.endpoint,
            path: config.path,
            method: 'POST',
            headers: reqHeaders
        };

        const req = https.request(options, (res) => {
            let data = '';

            res.on('data', (chunk) => {
                data += chunk;
            });

            res.on('end', () => {
                try {
                    const response = JSON.parse(data);

                    // 处理不同提供商的响应格式
                    let answer;
                    if (provider === 'deepseek' || provider === 'openai') {
                        if (response.error) {
                            console.error('API Error:', response.error);
                            reject(new Error(response.error.message || '提供商API错误'));
                            return;
                        }
                        answer = response.choices[0].message.content;
                    } else if (provider === 'gemini') {
                        if (response.error) {
                            console.error('API Error:', response.error);
                            reject(new Error(response.error.message || '提供商API错误'));
                            return;
                        }
                        answer = response.candidates[0].content.parts[0].text;
                    }

                    resolve(answer);
                } catch (e) {
                    console.error('解析响应失败:', e);
                    reject(new Error('无法解析API响应'));
                }
            });
        });

        req.on('error', (e) => {
            console.error('请求失败:', e);
            reject(e);
        });

        req.write(requestData);
        req.end();
    });
}

/**
 * 返回错误响应
 */
function errorResponse(message, statusCode = 500, headers = {}) {
    console.error('Error:', message);
    return {
        statusCode: statusCode,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            ...headers
        },
        body: JSON.stringify({
            error: message
        })
    };
}
