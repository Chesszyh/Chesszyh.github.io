# Copy Button

代码块复制功能允许用户一键复制 Markdown 中的代码片段。

## 实现方式

本博客使用的是 **MkDocs Material 主题内置** 的复制功能，而非独立的插件。这通常比外部插件更轻量且与主题集成更好。

## 配置

在 `mkdocs.yml` 的 `theme.features` 中启用：

```yaml
theme:
  features:
    - content.code.copy
```

## 演示

将鼠标悬停在下方的代码块上，右上角会出现一个复制图标：

```python
print("Click the copy button in the top right corner!")
```
