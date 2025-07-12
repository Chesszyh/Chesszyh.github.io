# 博客构建笔记

## Cusdis

[Cusdis](https://cusdis.com/)：开源评论系统，根据名字可以猜测是针对[Disqus](https://disqus.com/)的替代品。

[官方文档](https://cusdis.com/doc#)提到的特性，主要是轻便(5kb)、移植性好、不需要用户注册(在[Cusdis控制台](https://cusdis.com/dashboard/)审核评论后展示)。

- Universal embed code: You can embed Cusdis on every website.
- Light-weight sdk: The SDK that embed to your website is only 5kb (gzipped). Compared to Disqus (which is 24kb gzipped), it's very light-weight.
- Email notification
- One-click import data from Disqus
- Moderation dashboard: Since we don't require user sign in to comment, all comments are NOT displayed by default, until the moderator approve it. We provide a moderation dashboard for it.

### Hosted service Deployment

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

### Self host Deployment

自己部署，好处就是数据都在自己这里。不过我这小破博客也没啥必要了。

#### Docker

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

#### Railway or Vercel

都去参考官方文档就好，改改环境变量后一键部署就行。不过Railway有时会屏蔽我的ip，需要fork仓库之后手动部署。

## Chess

- [ChessGround](https://github.com/lichess-org/chessground)
  - [Vue-ChessBoard](https://github.com/qwerty084/vue3-chessboard)
    - [Doc](https://qwerty084.github.io/vue3-chessboard-docs/stockfish.html)
    - TODO 这个项目很美观，以后研究一下配置明白！
  - [Lichess-chessground-examples](https://github.com/lichess-org/chessground-examples)
    - 运行了一下，功能很全面，稍微美化一下应该就很完美了
- [Stockfish Doc](https://github.com/official-stockfish/Stockfish/wiki/Download-and-usage)
  - [Stockfish.js](https://github.com/nmrugg/stockfish.js)
    - `npm install stockfish.js`