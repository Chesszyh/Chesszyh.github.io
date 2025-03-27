/**
 * AI 搜索功能 - 在所有页面上激活 AI 搜索模式
 */

// AI模式相关配置
const aiConfig = {
    deepseek: {
        prefix: "@deepseek ",
        logo: "/image/deepseek-logo.svg",
        name: "Ask DeepSeek",
        endpoint: "/api/ai/deepseek",
        apiVersion: "v1",
    },
    gemini: {
        prefix: "@gemini ",
        logo: "/image/gemini-logo.svg",
        name: "Ask Gemini",
        endpoint: "/api/ai/gemini",
        apiVersion: "v1",
    },
    openai: {
        prefix: "@openai ",
        logo: "/image/openai-logo.svg",
        name: "Ask ChatGPT",
        endpoint: "/api/ai/openai",
        apiVersion: "v1",
    },
};

// 全局变量
let isAiMode = false;
let currentAiProvider = null;

// 在所有页面上初始化AI搜索监听器
document.addEventListener("DOMContentLoaded", function () {
    // 获取搜索输入框
    const searchInput = document.getElementById("search-query");

    // 如果找到搜索框，添加监听器
    if (searchInput) {
        console.log("AI Search: 监听器已初始化");

        // 创建视觉指示器
        createAiIndicator();

        // 输入监听
        searchInput.addEventListener("input", function () {
            const query = searchInput.value;

            // 保存之前的状态
            const wasAiMode = isAiMode;
            const prevProvider = currentAiProvider;

            // 检查新状态
            checkAiMode(query);

            // 状态变化时更新UI
            if (wasAiMode !== isAiMode || prevProvider !== currentAiProvider) {
                updateAiUI(searchInput);
            }
        });

        // 表单提交事件
        const searchForm = searchInput.closest("form");
        if (searchForm) {
            searchForm.addEventListener("submit", function (e) {
                const query = searchInput.value;

                // 检查是否是AI模式
                if (checkAiMode(query)) {
                    console.log("AI Search: 表单以AI模式提交");
                    // 已经有AI前缀，无需额外处理
                }
            });
        }

        // 初始检查当前值
        checkAiMode(searchInput.value);
        updateAiUI(searchInput);
    }
});

// 创建AI模式指示器
function createAiIndicator() {
    // 检查是否已存在
    if (document.querySelector(".ai-mode-indicator")) return;

    // 创建新的指示器
    const indicator = document.createElement("div");
    indicator.className = "ai-mode-indicator hidden fixed top-24 right-5 bg-green-500/20 text-green-400 px-3 py-1 rounded-full text-sm";
    indicator.innerHTML = 'AI Mode: <span id="ai-mode-text">DeepSeek</span>';
    indicator.style.zIndex = "100";
    indicator.style.animation = "fadeIn 0.3s ease-in-out";
    indicator.style.boxShadow = "0 2px 10px rgba(16, 185, 129, 0.3)";

    // 添加到body
    document.body.appendChild(indicator);

    // 添加样式
    const style = document.createElement("style");
    style.textContent = `
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(-10px); }
      to { opacity: 1; transform: translateY(0); }
    }
    input.ai-input {
      box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.2) !important;
      transition: all 0.2s ease-in-out !important;
      border-color: #10B981 !important;
      border-width: 2px !important;
    }
  `;
    document.head.appendChild(style);
}

// 检查是否处于AI模式
function checkAiMode(query) {
    isAiMode = false;
    currentAiProvider = null;

    // 检查是否有任何AI提供商的前缀
    if (query) {
        for (const [provider, config] of Object.entries(aiConfig)) {
            if (query.toLowerCase().startsWith(config.prefix.toLowerCase())) {
                isAiMode = true;
                currentAiProvider = provider;
                console.log(`AI Search: 检测到 ${provider} 模式`);
                break;
            }
        }
    }

    return isAiMode;
}

// 更新搜索UI以反映当前模式
function updateAiUI(inputElement) {
    // 获取模式指示器
    const modeIndicator = document.querySelector(".ai-mode-indicator");
    if (!modeIndicator) return;

    // 如果处于AI模式
    if (isAiMode && currentAiProvider) {
        const config = aiConfig[currentAiProvider];
        const modeText = document.getElementById("ai-mode-text");
        if (modeText) {
            modeText.textContent = config.name.replace("Ask ", "");
        }

        // 显示指示器
        modeIndicator.classList.remove("hidden");

        // 给输入框添加AI样式
        inputElement.classList.add("ai-input");

        console.log(`AI Search: 已激活 ${currentAiProvider} 模式`);
    } else {
        // 隐藏指示器
        modeIndicator.classList.add("hidden");

        // 移除AI样式
        inputElement.classList.remove("ai-input");

        console.log("AI Search: 标准搜索模式");
    }
}
