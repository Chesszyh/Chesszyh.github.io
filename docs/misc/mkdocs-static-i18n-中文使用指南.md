# mkdocs-static-i18n 插件中文使用指南

本文档根据 `mkdocs-static-i18n` 插件的现有功能和配置, 结合实际使用场景, 总结了一份详尽的中文使用说明和最佳实践.

## 1. 插件简介

`mkdocs-static-i18n` 是一个强大的 MkDocs 插件, 旨在帮助您轻松地为项目文档构建和维护多个语言版本. 它的核心理念是 "约定优于配置", 通过简单的文件命名或目录结构规则, 即可实现完整的国际化 (i18n) 支持.

### 核心功能

*   **多语言支持**: 可以为任意数量的语言创建对应的文档版本.
*   **静态化构建**: 为每种语言生成完全独立, 静态的 HTML 站点, 便于部署.
*   **灵活的内容组织**: 支持两种主流的国际化内容组织方式: 文件名后缀 (Suffix) 和目录结构 (Folder).
*   **本地化资源**: 不仅支持 Markdown 内容, 还支持图片, PDF 等静态资源的本地化.
*   **导航翻译**: 可以轻松翻译导航栏的标题, 甚至为不同语言提供完全不同的导航结构.
*   **配置覆盖**: 允许为每种语言覆盖 `mkdocs.yml` 中的几乎所有配置, 如站点名称 (`site_name`), 主题颜色 (`theme`), 版权信息 (`copyright`) 等.
*   **智能回退**: 当某个页面在当前语言不存在时, 可以自动回退到默认语言的对应页面, 避免 404 错误.
*   **良好的集成性**: 特别是与 `Material for MkDocs` 主题深度集成, 可以自动配置语言切换器和搜索插件.

## 2. 安装

通过 pip 可以轻松安装:

```bash
pip install mkdocs-static-i18n
```

## 3. 内容组织策略

插件支持两种组织多语言内容的方式, 您可以根据项目规模和个人偏好选择其一.

### 策略一: Suffix (文件名后缀)

这是插件的默认策略. 您只需将翻译后的文件名加上 `.语言代码` 的后缀即可.

**目录结构示例:**
```
docs/
├── index.md          # 默认语言 (如 en) 的首页
├── index.zh.md       # 中文版的首页
├── getting-started.md
├── getting-started.zh.md
└── assets/
    ├── image.png
    └── image.zh.png  # 本地化的图片
```

### 策略二: Folder (目录)

此策略更适合大型项目, 结构清晰. 您需要将不同语言的内容分别存放在以语言代码命名的子目录中.

**目录结构示例:**
```
docs/
├── en/
│   ├── index.md
│   └── getting-started.md
└── zh/
    ├── index.md
    └── getting-started.md
```

### **重要: 关于不支持的目录结构**

需要特别注意的是, MkDocs 的设计要求所有文档源文件都必须位于一个统一的 `docs_dir` 目录下. 因此, 像下面这样将不同语言的 `docs` 目录并列存放的结构是 **不被支持的**:

```
# 错误且不被支持的结构
.
├── docs/       # 存放英文
├── docs_zh/    # 存放中文
└── mkdocs.yml
```

即使yml文件设置为：

```yml
docs_dir: .

plugins:
  - search
  - i18n:
      docs_structure: 'folder'      # 使用 'folder' 结构
      languages:
        - locale: docs
          default: true
          name: English
          build: true
        - locale: docs_zh
          name: 中文
          build: true
```

也依然会报错：

```
ERROR   -  Config value 'plugins': Plugin 'i18n' option 'languages': Sub-option 'locale': Language code values must be either ISO-639-1 lower case or
           represented with their territory/region/country codes, received 'docs' expected forms examples: 'en' or 'en-US' or 'en_US'.
```

**正确的做法是采用 `Folder` 策略, 将不同语言的目录统一放到一个根 `docs` 目录下，并正确指定语言名称。**

## 4. 核心配置 (`mkdocs.yml`)

以下是一个完整的使用 `Folder` 结构, 支持**英文 (en)** 和**简体中文 (zh)** 的 `mkdocs.yml` 配置文件示例. 英文为默认语言.

```yaml
# 网站全局信息
site_name: My Project Docs # 默认站点名称, 会被各语言覆盖
site_url: https://example.com/
site_author: Your Name
copyright: 'Copyright © 2024 Your Name'

# 指定统一的文档源目录
docs_dir: docs

# 主题配置 (以 Material for MkDocs 为例)
theme:
  name: material
  language: en # 主题的默认 UI 语言
  features:
    - navigation.tabs
    - content.code.copy
  palette:
    - scheme: default
      primary: indigo
    - scheme: slate
      primary: black

# 插件配置
plugins:
  - search # 搜索插件, i18n 插件会自动为其配置多语言
  - i18n:
      # 核心配置
      docs_structure: 'folder'      # 使用 'folder' 结构, 与我们的目录结构对应
      fallback_to_default: true     # 如果中文页面不存在, 则回退到英文版

      # 定义支持的语言列表
      languages:
        # 英文配置 (默认语言)
        # 插件会去 docs/en/ 目录寻找源文件
        - locale: en
          default: true             # 设为默认语言
          name: English             # 在语言切换器中显示的名称
          build: true               # 构建此语言版本
          site_name: My Project Docs # 英文版的站点标题

        # 中文配置
        # 插件会去 docs/zh/ 目录寻找源文件
        - locale: zh
          name: 简体中文
          build: true
          site_name: 我的项目文档      # 中文版的站点标题
          # 为中文版覆盖主题语言, 以便显示 "上一页", "下一页" 等中文界面文本
          theme:
            language: zh
          # 翻译导航栏标题
          nav_translations:
            Home: 首页
            User Guide: 用户指南

# 默认导航结构 (路径相对于 en/ 或 zh/ 目录, 不需要写语言代码)
nav:
  - Home: index.md
  - User Guide: guide.md
```

## 5. 完整使用步骤总结

1.  **安装插件**: `pip install mkdocs-static-i18n`.
2.  **确定目录结构**: 推荐使用 `Folder` 策略. 新建一个 `docs` 目录, 然后在其中创建 `en`, `zh` 等语言子目录.
3.  **迁移内容**: 将您对应语言的 Markdown 文件和资源文件放入相应的语言目录中.
4.  **配置 `mkdocs.yml`**: 使用上方的示例作为模板, 根据您的需求修改 `site_name`, `nav` 等信息. 确保 `docs_dir` 和 `docs_structure` 的配置正确无误.
5.  **本地预览**: 在项目根目录运行 `mkdocs serve`, 打开浏览器访问 `http://127.0.0.1:8000` 即可看到您的多语言站点, 并可通过右上角的语言切换器进行切换.
6.  **构建**: 运行 `mkdocs build` 来生成最终的静态网站, 生成的内容在 `site` 目录下. 默认语言在根目录, 其他语言在 `/语言代码/` 子目录中.
