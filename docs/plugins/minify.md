# Minify Plugin

`mkdocs-minify-plugin` 用于在构建过程中压缩 HTML、JS 和 CSS 文件。这可以显著减小生成的静态站点的大小，提高加载速度。

## 功能

- **HTML 压缩**：移除多余的空格、注释等。
- **JS/CSS 压缩**：压缩内联或引用的脚本和样式表。

## 配置

在 `mkdocs.yml` 中：

```yaml
plugins:
  - minify:
      minify_html: true
      minify_js: true
      minify_css: true
```

注意：压缩可能会导致某些依赖特定格式的脚本失效，建议在启用后仔细测试。
