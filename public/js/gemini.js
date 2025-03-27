document.addEventListener('DOMContentLoaded', function () {
    const chatMessages = document.getElementById('chat-messages');
    const userInput = document.getElementById('user-input');
    const sendButton = document.getElementById('send-button');

    // 获取URL中的查询参数
    const urlParams = new URLSearchParams(window.location.search);
    const initialQuery = urlParams.get('query');

    // 如果URL中有查询参数，则自动填充到输入框并发送
    if (initialQuery) {
        userInput.value = decodeURIComponent(initialQuery);
        setTimeout(() => {
            sendMessage();
        }, 500);
    }

    // 添加发送按钮点击事件
    sendButton.addEventListener('click', sendMessage);

    // 添加回车键发送功能（Shift+Enter 换行）
    userInput.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    // 发送消息的函数
    function sendMessage() {
        const message = userInput.value.trim();
        if (message) {
            // 添加用户消息到聊天窗口
            appendMessage(message, 'user');
            userInput.value = '';

            // 显示等待指示器
            showTypingIndicator();

            // 调用Gemini API (示例实现，需要配置实际API)
            fetchGeminiResponse(message)
                .then(response => {
                    // 隐藏等待指示器
                    hideTypingIndicator();
                    // 添加机器人回复
                    appendMessage(response, 'bot');
                })
                .catch(error => {
                    console.error('Error:', error);
                    hideTypingIndicator();
                    appendMessage('抱歉，发生了一个错误，请稍后再试。', 'bot');
                });
        }
    }

    // 添加消息到聊天窗口
    function appendMessage(text, sender) {
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${sender}-message`;

        // 处理可能的Markdown内容
        if (sender === 'bot') {
            // 这里可以添加Markdown解析库，例如marked.js
            // 暂时简单处理
            messageDiv.innerHTML = text
                .replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>')
                .replace(/\n/g, '<br>');
        } else {
            messageDiv.textContent = text;
        }

        chatMessages.appendChild(messageDiv);
        // 自动滚动到底部
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    // 显示输入指示器
    function showTypingIndicator() {
        const indicatorDiv = document.createElement('div');
        indicatorDiv.className = 'typing-indicator';
        indicatorDiv.id = 'typing-indicator';
        indicatorDiv.innerHTML = '<span></span><span></span><span></span>';
        chatMessages.appendChild(indicatorDiv);
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    // 隐藏输入指示器
    function hideTypingIndicator() {
        const indicator = document.getElementById('typing-indicator');
        if (indicator) {
            indicator.remove();
        }
    }

    // 调用Gemini API
    async function fetchGeminiResponse(message) {
        try {
            const { GoogleGenerativeAI } = require("@google/generative-ai");
            
            // 从环境变量获取API密钥
            const API_KEY = process.env.GEMINI_API_KEY;
            if (!API_KEY) {
                throw new Error('GEMINI_API_KEY environment variable is not set');
            }

            const genAI = new GoogleGenerativeAI(API_KEY);
            const model = genAI.getGenerativeModel({ model: "gemini-pro" });

            const result = await model.generateContent(message);
            return result.response.text();
        } catch (error) {
            console.error('Gemini API Error:', error);
            throw new Error('Failed to get response from Gemini API');
        }
    }
});