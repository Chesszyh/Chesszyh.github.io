# Include Markdown Plugin

`mkdocs-include-markdown-plugin` 允许你在 Markdown 文件中包含（include）其他 Markdown 文件的内容。这对于复用通用的文档片段（如警告、页脚、配置说明）非常有用。

## 使用方法

使用特殊的语法：

```plaintext
{% include "./test.md" %}
```

或者包含特定部分：

```plaintext
{% include "./test.md" start="<!-- start -->" end="<!-- end -->" %}
```

## 示例

假设你有一个 `_footer.md` 文件，你可以在每个页面的底部包含它，而无需复制粘贴。
