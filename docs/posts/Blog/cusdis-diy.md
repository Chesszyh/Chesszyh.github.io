# Cusdis 自定义特性分析

## 1. 主题设置

```javascript
// 通过 data-theme 属性设置初始主题
// 支持的值: "light", "dark", "auto"
data-theme="dark"

// 通过 JavaScript API 动态设置主题
window.CUSDIS.setTheme('dark'); // 可选值: 'light', 'dark'
```

## 2. 主机和脚本路径自定义

```javascript
// 自定义 Cusdis 主机
data-host="https://cusdis.com"  // 默认值

// 自定义 iframe 脚本路径
data-iframe="自定义路径"  // 默认为 `${host}/js/iframe.umd.js`
```

## 3. 国际化支持

```javascript
// 可以通过设置 window.CUSDIS_LOCALE 对象自定义界面文本
window.CUSDIS_LOCALE = {
  powered_by: '评论由 Cusdis 提供',
  post_comment: '发表评论',
  loading: '加载中...',
  // 其他可自定义的文本...
};
```

## 4. 渲染控制

```javascript
// 阻止初始自动渲染
window.CUSDIS_PREVENT_INITIAL_RENDER = true;

// 手动渲染到特定元素
window.CUSDIS.renderTo(document.querySelector('#custom_element'));

// 指定渲染目标的ID
window.cusdisElementId = 'custom_thread_id';

// 手动初始化
window.CUSDIS.initial();
```

## 5. 评论数据配置

```javascript
// 页面ID - 用于标识评论所属页面
data-page-id="{{ .File.UniqueID }}"

// 页面URL - 用于在管理界面链接到原页面
data-page-url="{{ .Permalink }}"

// 页面标题 - 在管理界面显示
data-page-title="{{ .Title }}"

// 应用ID - 您的 Cusdis 应用标识符
data-app-id="your-app-id"
```

## 6. 颜色方案检测

代码中包含了针对系统颜色方案的检测:

```javascript
const darkModeQuery = window.matchMedia("(prefers-color-scheme: dark)");
```

当设置 `data-theme="auto"` 时，Cusdis 会根据用户系统偏好自动切换主题。

## 7. iframe 交互机制

Cusdis 使用 iframe 和 postMessage 进行父页面与评论 iframe 之间的通信:

```javascript
// 监听来自 iframe 的消息
window.addEventListener("message", onMessage);

// 向 iframe 发送消息
postMessage("setTheme", theme);
```

## 8. 响应式高度调整

```javascript
// iframe 高度会根据内容自动调整
case "resize": {
  iframe.style.height = msg.data + "px";
}
```

## 实用的自定义建议

1. **本地化文本**:
   ```javascript
   <script>
     window.CUSDIS_LOCALE = {
       powered_by: '评论由 Cusdis 提供',
       post_comment: '发表评论',
       loading: '加载中...',
       // 添加更多中文本地化文本
     }
   </script>
   ```

2. **自托管 Cusdis**:
   如果需要更多自定义，可以考虑自托管 Cusdis 服务，这样可以完全控制 CSS 和功能。

3. **主题切换与系统同步**:
   ```javascript
   <div id="cusdis_thread" data-theme="auto"></div>
   ```

4. **手动控制渲染时机**:
   ```javascript
   <script>
     window.CUSDIS_PREVENT_INITIAL_RENDER = true;
     // 在某个事件触发后再渲染评论
     document.getElementById('show-comments').addEventListener('click', () => {
       window.CUSDIS.renderTo(document.querySelector('#cusdis_thread'));
     });
   </script>
   ```

这些自定义特性使 Cusdis 可以很好地适应不同网站的需求和设计。您可以根据自己的需要选择合适的自定义方式，提升评论系统与您网站的整合度。