# Awesome Pages Plugin

`mkdocs-awesome-pages-plugin` 是一个强大的导航自定义插件，它允许你通过在目录中放置 `.pages` 文件来控制 MkDocs 的导航结构，而无需在 `mkdocs.yml` 中手动维护冗长的 `nav` 配置。

## 功能特性

- **自定义排序**：按需对页面和子目录进行排序。
- **隐藏页面**：从导航栏中隐藏特定页面。
- **重命名**：自定义目录在导航栏中的显示名称。
- **自动发现**：自动发现新文件并添加到导航中。

## 使用示例

在任意目录下创建一个 `.pages` 文件（YAML 格式）：

```yaml
title: 我的目录标题
arrange:
  - index.md
  - guide.md
  - advanced/
  - ...
```

这样 `index.md` 会排在第一位，`guide.md` 第二，`advanced` 目录第三，其他文件按字母顺序排列。
