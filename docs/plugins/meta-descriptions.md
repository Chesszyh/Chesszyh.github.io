# Meta Descriptions Plugin

`mkdocs-meta-descriptions-plugin` 会自动从每个页面的内容（通常是第一段）生成 HTML `<meta name="description">` 标签。

## 作用

- **SEO 优化**：搜索引擎通常使用 meta description 来显示搜索结果的摘要。
- **自动化**：无需手动为每个页面编写 description front-matter。

## 配置

该插件通常开箱即用，无需复杂配置。它会扫描 Markdown 内容并提取摘要。你也可以在 front-matter 中手动指定 `description` 来覆盖自动生成的内容。

```yaml
---
description: 这是一个自定义的页面描述，用于 SEO。
---
```
