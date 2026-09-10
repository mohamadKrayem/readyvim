# ReadyVim

> A dark, batteries-included Neovim + tmux config. nvim, tmux, lazygit & lf wired to work as one.

**[mohamadkrayem.github.io/readyvim-site](https://mohamadkrayem.github.io/readyvim-site/)** — install steps, keymaps and the rest, on one page.

Configuration for the tools I actually live in: Neovim, tmux, lf and lazygit.
They're wired together — the same `Ctrl+h/j/k/l` crosses nvim splits and tmux panes,
lazygit opens files back into the nvim instance that launched it, and lf runs as
the file manager inside nvim (`<leader>-`), replacing netrw.

```
nvim/       Neovim config (lazy.nvim)
tmux/       standalone tmux.conf + tmux-sessionizer, the project switcher
lf/         lf file manager — the one nvim opens
yazi/       yazi file manager — kept, but disabled in favour of lf
lazygit/    lazygit, including the "open in parent nvim" integration
install.sh  symlinks everything into place
```

## Install

```bash
git clone git@github.com:mohamadKrayem/readyvim.git ~/personal/dotfiles
cd ~/personal/dotfiles
./install.sh
```

`install.sh` moves anything already at those paths into a timestamped
`~/.dotfiles-backup-*` directory before linking, and is safe to re-run.

To try the Neovim config without touching an existing one — no symlinks, no
`install.sh`, nothing written outside the clone:

```bash
git clone git@github.com:mohamadKrayem/readyvim.git ~/personal/dotfiles
XDG_CONFIG_HOME=~/personal/dotfiles nvim
```

(`NVIM_APPNAME` won't work here — it resolves under `~/.config`, so it can't
reach a clone living anywhere else.)

## Try it in Docker

Test the whole setup in a throwaway container — no symlinks, nothing installed
on your machine:

```bash
make docker-test
```

This builds a Linux image with all the tools, runs `install.sh`, pre-installs
the Neovim plugins, and drops you into a themed tmux session. See
[docker/README.md](docker/README.md) for details and a live-mount dev workflow.

## Requirements

| | |
|---|---|
| Neovim | 0.11+ (uses `vim.diagnostic.jump`, `vim.hl`) |
| git, ripgrep, fd | telescope pickers |
| a C compiler + make | treesitter parsers |
| node | several LSP servers |
| python3 | basedpyright, debugpy |
| tmux | 3.2+ (floating popups) |
| fzf | `prefix + f` project switcher |
| lf | file manager, opened from nvim and as netrw's replacement |
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

## lf

The file manager nvim opens with `<leader>-` (with the cursor already on the
current file) and `<leader>cw` (working directory). It also takes over netrw,
so `nvim .` lands in lf.

`y` is a prefix for the clipboard, so the built-in copy is `yy`:

| key | copies |
|---|---|
| `yn` / `ys` | file name / name without extension |
| `yp` / `yd` | absolute path / containing directory |
| `yr` | path relative to the repo root |

`af` / `ad` create a file / directory, `D` deletes (with confirmation), `o`
opens with the system default app. Multi-file selections work throughout.
Clipboard support is macOS-only (`pbcopy`).

## tmux

Standalone, no framework. Prefix is `Ctrl+b` (with `Ctrl+a` as a second prefix).
Splits `-` / `_`, pane movement `prefix + h/j/k/l`, and `Ctrl+h/j/k/l` without a
prefix to move seamlessly between nvim splits and tmux panes.

Floating popups: `prefix + t` scratch shell, `prefix + g` lazygit, `prefix + e`
edit this config. In copy-mode, `Ctrl+p` / `Ctrl+n` jump 8 lines.

A session per project, so switching away and back costs nothing — nvim keeps
its tabs and LSP clients, and whatever is running in the other pane keeps its
state. `prefix + f` fzf-picks a project and switches to its session, creating
it on first use with nvim and claude side by side (`tmux/tmux-sessionizer`,
roots configurable via `TMUX_SESSIONIZER_PATHS`). `prefix + s` lists sessions,
`prefix + Shift-Tab` bounces back to the last one.
