# Copilot Instructions for Chesszyh's Blog

This is a personal technical blog built with **MkDocs Material**, featuring multilingual content and custom theming. The site covers technical topics across Linux, Web Development, LLM/AI, Chess, and more.

## Architecture Overview

- **Framework**: MkDocs with Material theme (`mkdocs-material>=9.6.0`)
- **Content**: Markdown files in `docs/` with primarily Chinese content and English technical terms
- **Styling**: Custom CSS in `docs/stylesheets/extra.css` with dark theme enhancements and purple accent colors
- **Deployment**: GitHub Actions workflow deploys to GitHub Pages on master branch pushes
- **Domain**: Custom domain `blog.neurosama.uk` (configured via CNAME)

## Content Patterns & Conventions

### File Organization

- Main content in `docs/posts/` organized by topic (LLM/, Linux/, Web/, etc.)
- Summary files for time-based content in `docs/summary/`
- Miscellaneous notes in `docs/misc/`
- Assets (images) colocated with content files

### Writing Style

- **Mixed Language**: Chinese text with English technical terms and code blocks
- **Code Examples**: Extensive use of fenced code blocks with language specification
- **Technical Documentation**: Step-by-step guides with configuration examples
- **Translation Summaries**: English content often includes Chinese translation/summary sections

### Navigation Structure

- Hierarchical navigation defined in `mkdocs.yml` nav section
- Categories: Blog Tech, Chess, Database, Docker, Linux, LLM, Server, Web Development
- Use descriptive titles in navigation, different from file names when needed

## Development Workflow

### Local Development

```bash
python -m pip install -r requirements.txt
python -m mkdocs serve  # Defaults to localhost:8000
# Optional: --dev-addr=127.0.0.1:8000
```

### Build & Deploy

```bash
python -m mkdocs build  # Generates site/ directory
# Deployment handled automatically by GitHub Actions
```

### Content Creation

- Create new posts in appropriate `docs/posts/<category>/` directory
- Include in `mkdocs.yml` navigation manually (no auto-discovery)
- Use `.md` extension, colocate images with content
- Follow existing naming patterns (Chinese file names acceptable)

## Theme Customization

### Color Scheme

- **Primary**: Deep purple (`#7c3aed`) with gradients
- **Dark Mode**: Enhanced with `#0f0f0f` background and custom variables
- **Accent**: Purple variations for links and highlights
- **Code Blocks**: Dark theme with rounded corners and custom padding

### Custom Components

- Enhanced navigation with uppercase titles and font weights
- Gradient headers and sidebars
- Custom search box styling with purple accents
- Smooth hover transitions and animations
- Custom scrollbar styling

## Key Files to Understand

- `mkdocs.yml`: Complete site configuration, navigation, theme settings, plugins
- `docs/stylesheets/extra.css`: All visual customizations and dark theme enhancements
- `docs/index.md`: Homepage with contact info and technology overview
- `.github/workflows/deploy.yml`: Automated deployment pipeline
- `requirements.txt`: Python dependencies (MkDocs, Material theme, extensions)

## Markdown Extensions Enabled

- Admonitions, code highlighting, tabbed content, task lists
- Emoji support with Twemoji
- Table of contents, footnotes, definition lists
- Material-specific extensions for enhanced formatting

When adding content, follow the established multilingual pattern and ensure proper navigation updates in `mkdocs.yml`.
