# Contributing to tmux-fzf-open-files-nvim

Thanks for your interest in contributing! This project is meant to be minimal, efficient, and BASH! Below are a few guidelines to help you get started.

## Getting Started

1. **Fork the repository**
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/tmux-fzf-open-files-nvim
   cd tmux-fzf-open-files-nvim```
3. Create a new branch for your fix or feature.

## Best Practices

- Stick to Bash best practices. This project uses shellcheck in a github action to enforce best practices, which will block PR merges. You can also check out the shellcheck web version here: https://www.shellcheck.net/
- Avoid adding external dependencies. We want this to be as minimal as possible. If it's annoying to install for development, it will also annoy other users.

## If you change keybindings or core behavior:

Update the README.md relevant sections
Think about adding a user defined tmux option to enable / disable the new behavior. This will allow users to opt-in to new behavior.
```bash
set -g @tmux-open-file-nvim-search-all-windows on
```

## Creating a pull request

- Please follow the PR template and make sure to provide a screenshot, gif, or video showing the new behavior or bug fix.

Thanks again for helping improve tmux-fzf-open-files-nvim!
