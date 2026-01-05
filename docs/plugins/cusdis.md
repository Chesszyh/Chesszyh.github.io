# Cusdis

[Cusdis](https://cusdis.com/)：开源评论系统，根据名字可以猜测是针对[Disqus](https://disqus.com/)的替代品。

[官方文档](https://cusdis.com/doc#)提到的特性，主要是轻便(5kb)、移植性好、不需要用户注册(在[Cusdis控制台](https://cusdis.com/dashboard/)审核评论后展示)。

- Universal embed code: You can embed Cusdis on every website.
- Light-weight sdk: The SDK that embed to your website is only 5kb (gzipped). Compared to Disqus (which is 24kb gzipped), it's very light-weight.
- Email notification
- One-click import data from Disqus
- Moderation dashboard: Since we don't require user sign in to comment, all comments are NOT displayed by default, until the moderator approve it. We provide a moderation dashboard for it.

## Hosted service Deployment

无需自己创建数据库，而是使用官方提供的Vercel+PostgreSQL DB. 使用时只需要嵌入代码并做好相应设置即可。

嵌入位置：`/layouts/_default/single.html`

```html
    <!-- Comments by Cusdis -->
    <h4 class="text-gray-300 mt-8 mb-4">Comments:</h4>
    <div id="cusdis_thread" 
        data-host="https://cusdis.com"
        data-app-id="1d03ca2b-8748-4bd8-9a3f-52c7c195dd18"
        data-page-id="{{ .File.UniqueID }}" 
        data-page-url="{{ .Permalink }}"
        data-page-title="{{ .Title }}"
        data-theme="dark"></div>
    <script async defer src="https://cusdis.com/js/cusdis.es.js"></script>

    <!-- Cusdis通过 iframe 加载评论系统，默认的背景在我博客的黑色背景下显示异常，而外加CSS样式无法影响到 iframe 内部的内容。
     因此，添加如下的小脚本，在页面加载后强制设置主题为暗色。-->

    <script>
    // 等待Cusdis加载完成
    document.addEventListener('DOMContentLoaded', () => {
        // 给系统一些时间来加载iframe
        setTimeout(() => {
        // 强制设置主题为暗色
        if (window.CUSDIS && window.CUSDIS.setTheme) {
            window.CUSDIS.setTheme('dark');
        }
        }, 1000);
    });
    </script>
```

## Self host Deployment

自己部署，好处就是数据都在自己这里。不过我这小破博客也没啥必要了。

### Docker

`USERNAME`/`PASSWORD`都参考你数据库初始化时设置的值。`JWT_SECRET`可以随意设置，`NEXTAUTH_URL`是数据库终端节点。

```shell
docker run -d \                                                                                                              
  -e USERNAME="" \
  -e PASSWORD="" \
  -e JWT_SECRET="" \    
  -e DB_URL=file:/data/db.sqlite \
  -e NEXTAUTH_URL="" \
  -p 3000:3000 \
  -v /data:/data \
  djyde/cusdis
```

### Railway or Vercel

都去参考官方文档就好，改改环境变量后一键部署就行。不过Railway有时会屏蔽我的ip，需要fork仓库之后手动部署。

## Cusdis 自定义特性

### 1. 主题设置

```javascript
// 通过 data-theme 属性设置初始主题
// 支持的值: "light", "dark", "auto"
data-theme="dark"

// 通过 JavaScript API 动态设置主题
window.CUSDIS.setTheme('dark'); // 可选值: 'light', 'dark'
```

### 2. 主机和脚本路径自定义

```javascript
// 自定义 Cusdis 主机
data-host="https://cusdis.com"  // 默认值

// 自定义 iframe 脚本路径
data-iframe="自定义路径"  // 默认为 `${host}/js/iframe.umd.js`
```

### 3. 国际化支持

```javascript
// 可以通过设置 window.CUSDIS_LOCALE 对象自定义界面文本
window.CUSDIS_LOCALE = {
  powered_by: '评论由 Cusdis 提供',
  post_comment: '发表评论',
  loading: '加载中...',
  // 其他可自定义的文本...
};
```

### 4. 渲染控制

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

### 5. 评论数据配置

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

### 6. 颜色方案检测

代码中包含了针对系统颜色方案的检测:

```javascript
const darkModeQuery = window.matchMedia("(prefers-color-scheme: dark)");
```

当设置 `data-theme="auto"` 时，Cusdis 会根据用户系统偏好自动切换主题。

### 7. iframe 交互机制

Cusdis 使用 iframe 和 postMessage 进行父页面与评论 iframe 之间的通信:

```javascript
// 监听来自 iframe 的消息
window.addEventListener("message", onMessage);

// 向 iframe 发送消息
postMessage("setTheme", theme);
```

### 8. 响应式高度调整

```javascript
// iframe 高度会根据内容自动调整
case "resize": {
  iframe.style.height = msg.data + "px";
}
```

### 实用的自定义建议

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