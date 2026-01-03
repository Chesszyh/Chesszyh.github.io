# Code Include Plugin

`mkdocs-codeinclude-plugin` 允许你直接从外部文件导入代码片段到 Markdown 文档中。这对于展示实际项目中的代码非常有用，可以避免代码重复和过时。

## 使用方法

使用特殊的语法来引用文件：

    <!-- codeinclude: path/to/file.py -->

或者指定语言和行号范围：

    <!-- codeinclude: path/to/file.js language:javascript lines:1-10 -->

## 示例

假设有一个 `hello.py` 文件：

```python
def hello():
    print("Hello, World!")
```

在 Markdown 中引用它，就会自动渲染为带有语法高亮的代码块。
