# xrepl/term

[![Build Status][gh-actions-badge]][gh-actions]
[![LFE Versions][lfe-badge]][lfe]
[![Erlang Versions][erlang-badge]][version]
[![Tags][github-tags-badge]][github-tags]

[![Project Logo][logo]][logo-large]

*A modern terminal control library for LFE*

## Features

- **ANSI Colours & Styles** - Rich text formatting with composable DSL
- **Inline Graphics** - Display images via iTerm2, Kitty, and Sixel protocols
- **Hyperlinks** - Clickable terminal links (OSC 8)
- **Notifications** - Desktop notifications from terminal
- **UI Components** - Tables, progress bars, tree views
- **Auto-detection** - Automatically detect terminal capabilities
- **Zero Dependencies** - Pure Erlang/LFE implementation

## Installation

Add to your `rebar.config`:

```erlang
{deps, [
    {xrepl_term, {git, "https://github.com/xrepl/term.git", {branch, "main"}}}
]}.
```

## Quick Start

```lfe
;; Include colour macros
(include-lib "xrepl_term/include/colours.lfe")

;; Basic styling
(io:format "~s~n" (list (red! "Error: " (bold! "File not found"))))

;; Threading macro style
(clj:-> "Important Message"
  (bold!)
  (fg! 'cyan)
  (underline!)
  (list)
  (io:format "~s~n"))

;; Display image
(xrepl-term-graphics:render-file "chart.png" #m(width "80%"))

;; Create table
(xrepl-term-ui:table
  #m(headers '("Name" "Age" "City")
     rows '(("Alice" 30 "NYC")
            ("Bob" 25 "SF"))))
```

## Documentation

See [examples/](examples/) for more usage patterns.

## License

Apache-2.0

[//]: ---Named-Links---

[logo]: https://raw.githubusercontent.com/xrepl/xrepl/refs/heads/main/priv/images/logo-v1-x250.png
[logo-large]: https://raw.githubusercontent.com/xrepl/xrepl/refs/heads/main/priv/images/logo-v1-x4800.png
[gh-actions-badge]: https://github.com/xrepl/term/actions/workflows/cicd.yml/badge.svg
[gh-actions]: https://github.com/xrepl/term/actions/workflows/cicd.yml
[lfe]: https://github.com/lfe/lfe
[lfe-badge]: https://img.shields.io/badge/lfe-2.2-blue.svg
[erlang-badge]: https://img.shields.io/badge/erlang-25%20to%2028-blue.svg
[version]: https://github.com/xrepl/term/blob/main/.github/workflows/cicd.yml
[github-tags]: https://github.com/xrepl/term/tags
[github-tags-badge]: https://img.shields.io/github/tag/lfe/xrepl.svg
