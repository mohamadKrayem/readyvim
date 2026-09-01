# dotfiles

Configuration for the four tools I actually live in: Neovim, tmux, yazi and lazygit.
They're wired together — the same `Ctrl+h/j/k/l` crosses nvim splits and tmux panes,
lazygit opens files back into the nvim instance that launched it, and yazi runs as
the file manager inside nvim.

```
nvim/       Neovim config (lazy.nvim)
tmux/       standalone tmux.conf — no oh-my-tmux, no framework
yazi/       yazi file manager
lazygit/    lazygit, including the "open in parent nvim" integration
install.sh  symlinks everything into place
```

## Install

```bash
git clone <this-repo> ~/personal/dotfiles
cd ~/personal/dotfiles
./install.sh
```

`install.sh` moves anything already at those paths into a timestamped
`~/.dotfiles-backup-*` directory before linking, and is safe to re-run.

To try the Neovim config without touching an existing one — no symlinks, no
`install.sh`, nothing written outside the clone:

```bash
git clone <this-repo> ~/personal/dotfiles
XDG_CONFIG_HOME=~/personal/dotfiles nvim
```

(`NVIM_APPNAME` won't work here — it resolves under `~/.config`, so it can't
reach a clone living anywhere else.)

## Requirements

| | |
|---|---|
| Neovim | 0.11+ (uses `vim.diagnostic.jump`, `vim.hl`) |
| git, ripgrep, fd | telescope pickers |
| a C compiler + make | treesitter parsers |
| node | several LSP servers |
| python3 | basedpyright, debugpy |
| tmux | 3.2+ (floating popups) |
| lazygit, yazi | optional, but the integrations expect them |

A **Nerd Font** is required for Neovim — the statusline, bufferline and diagnostic
signs all use glyphs. The tmux config is deliberately ASCII-only and needs no
special font.

Language servers and debug adapters install themselves through Mason on first run.

## Neovim layout

```
init.lua              leader keys, then load order
lua/config/
  lazy.lua            lazy.nvim bootstrap + which plugin folders to import
  options.lua         editor settings
  keymaps.lua         global keymaps (plugin keymaps live with their plugin)
  diagnostics.lua     diagnostic appearance
  autocmds.lua        autocommands
lua/plugins/
  ui/ editor/ lsp/ git/ ai/ debug/
```

Adding a plugin means dropping a file into the matching folder — `lua/config/lazy.lua`
imports folders, not individual files.

See [nvim/SHORTCUTS.md](nvim/SHORTCUTS.md) for the full keymap reference.

## tmux

Standalone, no framework. Prefix is `Ctrl+b` (with `Ctrl+a` as a second prefix).
Splits `-` / `_`, pane movement `prefix + h/j/k/l`, and `Ctrl+h/j/k/l` without a
prefix to move seamlessly between nvim splits and tmux panes.

Floating popups: `prefix + t` scratch shell, `prefix + g` lazygit, `prefix + e`
edit this config. In copy-mode, `Ctrl+p` / `Ctrl+n` jump 8 lines.
