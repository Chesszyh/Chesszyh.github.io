# Git Revision Date Localized

`mkdocs-git-revision-date-localized-plugin` 会在每个页面的底部显示该文件的最后修改日期。这个日期是基于 Git 提交历史自动生成的。

## 功能

- **自动更新**：无需手动维护更新时间。
- **本地化格式**：支持多种语言和日期格式。
- **创建日期**：也可以显示文件的创建日期（基于第一次 commit）。

## 配置

在 `mkdocs.yml` 中：

```yaml
plugins:
  - git-revision-date-localized:
      enable_creation_date: true
      type: date
```

## 效果

在页面底部，你会看到类似这样的信息：

> Last update: 2025年1月4日
> Created: 2024年12月30日
