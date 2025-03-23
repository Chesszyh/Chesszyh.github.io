---
title: 'Site Introduction'
date: 2025-03-22T22:48:27+08:00
draft: true
categories: ["Web"]
tags: []
featuredImage: "/image/neuro_cat.jpg"

---

<!-- Article content starts -->
## Introduction

Theme: Based on [Hugo](https://github.com/gohugoio/hugo) with the [Niello](https://github.com/guangmean/Niello) theme.

For using this theme, refer to the [demo](https://www.angularcorp.com/en/) and [theme-home-page](https://themes.gohugo.io/themes/niello/).

## Extensions

- [Comment system reference](https://sspai.com/post/73412)
    - TODO

- [Github Issues comment system](https://jw1.dev/2022/10/23/a01/)
    - TODO

- [Google Analytics 4](https://analytics.google.com/analytics/web/provision/?authuser=0#/provision/create): For cookie tracking and website analytics

- [Chess](https://github.com/oakmac/chessboardjs)
    - [Demo](https://chessboardjs.com/examples#5005)
    - Used only for static page demonstrations, with future links to a chess interface equipped with [Stockfish](https://github.com/official-stockfish/Stockfish).

## Structure

```
my-website/
├── archetypes/               # Content templates
    ├── default.md           # Default template with predefined front matter format
├── assets/                   # Resources to be processed
    ├── css/                  
    ├── js/                   
    ├── scss/                 
├── content/                  # Website content
    ├── posts/                # Articles
    ├── about.md              
    ├── contact.md            
├── data/               
├── layouts/                  # HTML templates defining website structure and appearance
    ├── _default/             # Default templates defining overall page HTML structure
    ├── partials/             # Partial templates for reusable page components (header, footer, nav)
    ├── 404.html              
├── static/                   # Static resources
    ├── image/              
    ├── css/                  
    ├── js/
├── public/                   # Output directory after building the site, ready for deployment
├── themes/
└── config.toml/yaml/json     # Website configuration file
```

## Getting Started

- `hugo new posts/your-post-name.md`: Create a new article with automatic YAML front matter.
- `hugo server -D`: Run the site locally, default port is `localhost:1313`.
