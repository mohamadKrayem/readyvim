# ReadyVim

> A dark, batteries-included Neovim + tmux config. nvim, tmux, lazygit & lf wired to work as one.

**[mohamadkrayem.github.io/readyvim-site](https://mohamadkrayem.github.io/readyvim-site/)** — install steps, keymaps and the rest, on one page.

Configuration for the tools I actually live in: Neovim, tmux, lf and lazygit.
They're wired together — the same `Ctrl+h/j/k/l` crosses nvim splits and tmux panes,
lazygit opens files back into the nvim instance that launched it, and lf runs as
the file manager inside nvim (`<leader>-`), replacing netrw.

```
nvim/       Neovim config (lazy.nvim)
tmux/       standalone tmux.conf, tmux-sessionizer (projects), tmux-worktree (branches)
lf/         lf file manager — the one nvim opens
yazi/       yazi file manager — kept, but disabled in favour of lf
lazygit/    lazygit, including the "open in parent nvim" integration
install.sh  symlinks everything into place, clones the two tmux plugins
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
| ipykernel | optional, for the Python REPL (see below) |

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
  claude.lua          send code to the claude pane (<leader>ac)
  diagnostics.lua     diagnostic appearance
  autocmds.lua        autocommands
lua/plugins/
  ui/ editor/ lsp/ git/ ai/ debug/
```

Adding a plugin means dropping a file into the matching folder — `lua/config/lazy.lua`
imports folders, not individual files.

See [nvim/SHORTCUTS.md](nvim/SHORTCUTS.md) for the full keymap reference.

## Moving and editing

| key | does |
|---|---|
| `s` + letters + label | jump anywhere on screen ([flash.nvim](https://github.com/folke/flash.nvim)); `S` selects the treesitter node around the cursor |
| `gsa` / `gsd` / `gsr` | add / delete / replace surrounding quotes, brackets, tags: `gsaiw"` wraps a word, `gsr"'` swaps the quotes |
| `<leader>fr` | find and replace across the project with a live preview ([grug-far](https://github.com/MagicDuck/grug-far.nvim)); `Space r` applies it |
| `<leader>U` | undo history as a tree, including branches plain `u` can't reach |
| `[x` | jump up to the function or block pinned at the top of the window |

The enclosing function, class or block stays pinned at the top while you scroll
through it. `f` / `t` are plain vim; flash only takes `s`, which is why
surround lives under `gs`.

## Claude

With claude in the next tmux pane (the sessionizer's layout), `<leader>ac`
pastes `@path/to/file` into it; on a visual selection it pastes the path, the
line range and the code. Nothing is submitted — focus moves to claude so you
type the question and press Enter yourself.

`prefix + a` collapses the claude pane: the editor fills the window while
claude keeps running out of sight, and the window's tab shows `[zoomed]`.
Press it again — or move into it with `Ctrl+l` — and the old layout comes back
exactly, same split and width.

## Git review

[diffview.nvim](https://github.com/sindrets/diffview.nvim) shows changes the way
a pull request does: changed files on the left, a side-by-side diff on the
right. `<leader>gd` opens every uncommitted change, `<leader>gh` the history of
the current file, `<leader>gH` the branch's history. The same key or `q` closes
it; `-` stages the file under the cursor. lazygit is still the place to commit.

## Projects & worktrees

`<leader>sp` picks a project and switches this nvim to it: the current
directory's session is saved, its buffers and LSP clients are dropped, and the
target's session is restored with its tabs and splits. `<leader>sP` bounces
back to the previous one. Only nvim moves, so a neighbouring tmux pane running
a server or a log tail stays where it is.

`<leader>gw` does the same for the worktrees of the repo you are in, listing
each one by branch and marking the one you are currently in. Switching
worktrees is switching directory, so each keeps its own session.

To work on two branches side by side instead, `prefix + W` in tmux picks a
branch of the repo in the current pane — or takes a new name — creates the
worktree next to the repo as `<repo>-<branch>`, and opens it as its own tmux
session with nvim and claude. Picking a branch that already has a worktree just
switches to it.

Sessions are keyed by directory and never restored automatically — startup
stays predictable, and `<leader>sl` restores one when you want it. Project
roots come from `TMUX_SESSIONIZER_PATHS`, the same variable the tmux
sessionizer reads, so both pickers agree on what counts as a project.

## Python REPL

[jet.nvim](https://github.com/wurli/jet.nvim) runs a Jupyter kernel in a
terminal split and sends code to it from the buffer:

| key | does |
|---|---|
| `<leader>rr` | toggle the REPL, starting a kernel if none is running |
| `<leader>rs` | send the expression under the cursor and move to the next one; in visual mode, send the selection |
| `<leader>ro` | `:Jet`, the kernel manager (start, stop, rename) |

An expression is a whole statement, `def`, `class` or `for` block, so pressing
`<leader>rs` repeatedly walks through a script. A kernel from the project's own
virtualenv is preferred over the global one.

Two things are needed once. The first `:Jet` asks to download jet's engine
(answer `y`, or run `:Jet install`). And there has to be a Python kernel:

```bash
# once, for every project: a global kernel in its own venv
uv venv ~/.local/share/jupyter-kernel-venv
uv pip install --python ~/.local/share/jupyter-kernel-venv/bin/python ipykernel
~/.local/share/jupyter-kernel-venv/bin/python -m ipykernel install --user --name python3

# per project, so the REPL sees the project's packages
uv add --dev ipykernel
```

## Notes

[obsidian.nvim](https://github.com/obsidian-nvim/obsidian.nvim) turns
`~/personal/notes` into a notes vault: plain Markdown files that link to each
other. The Obsidian app isn't needed, though it can open the same folder.

| key | does |
|---|---|
| `<leader>on` | new note (the title becomes the file name: `Meeting notes` → `meeting-notes.md`) |
| `<leader>ot` | today's daily note, in `daily/` |
| `<leader>of` | find a note by name |
| `<leader>os` | search inside all notes |
| `<leader>ob` | backlinks: notes that link to this one |

Inside a note, typing `[[` completes note names, `Enter` follows a link or
toggles a checkbox, and `]o` / `[o` jump between links. markview does the
rendering. The plugin only loads for files in the vault, or when you use one
of the keys above.

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

Standalone, no framework. The prefix is `Ctrl+Space`, and it's the only one.
Press it twice to send a real `Ctrl+Space` to the program in the pane.
Splits `-` / `_`, pane movement `prefix + h/j/k/l`, and `Ctrl+h/j/k/l` without a
prefix to move seamlessly between nvim splits and tmux panes.

Floating popups: `prefix + t` scratch shell, `prefix + g` lazygit, `prefix + e`
edit this config, `prefix + n` today's note. `prefix + a` collapses / expands
the claude pane (see Claude). In copy-mode, `Ctrl+p` / `Ctrl+n`
jump 8 lines.

A session per project, so switching away and back costs nothing — nvim keeps
its tabs and LSP clients, and whatever is running in the other pane keeps its
state. `prefix + f` fzf-picks a project and switches to its session, creating
it on first use with nvim and claude side by side (`tmux/tmux-sessionizer`,
roots configurable via `TMUX_SESSIONIZER_PATHS`). `prefix + s` lists sessions,
`prefix + Ctrl+f` fzf-picks one of the open sessions, and `prefix + Shift-Tab`
bounces back to the last one. `prefix + W` opens another branch as a worktree
session (see Projects & worktrees).

Sessions survive a reboot. [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
and [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) save every
session, window, split and directory every 10 minutes and restore them when
tmux starts again: nvim reopens in its pane and claude comes back with
`--continue`, into the conversation it was in. `prefix + Ctrl+s` /
`prefix + Ctrl+r` save and restore by hand. `install.sh` clones both plugins;
there is no plugin manager.
