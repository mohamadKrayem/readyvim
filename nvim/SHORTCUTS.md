# Neovim Shortcuts Documentation

This document provides a comprehensive list of all keyboard shortcuts configured in your Neovim setup.

## Core Navigation

| Shortcut | Mode                   | Description                              |
| -------- | ---------------------- | ---------------------------------------- |
| `<C-p>`  | Normal/Visual          | Move 8 lines up                          |
| `<C-n>`  | Normal/Visual          | Move 8 lines down                        |
| `]i`     | Normal/Visual/Operator | Go to next unmatched closing bracket     |
| `[i`     | Normal/Visual/Operator | Go to previous unmatched opening bracket |
| `]i`     | Insert                 | Go to next unmatched closing bracket     |
| `[i`     | Insert                 | Go to previous unmatched opening bracket |

## Codeium AI Completion

| Shortcut | Mode   | Description                     |
| -------- | ------ | ------------------------------- |
| `<C-h>`  | Insert | Accept AI suggestion            |
| `<C-;>`  | Insert | Cycle to next AI completion     |
| `<C-,>`  | Insert | Cycle to previous AI completion |
| `<C-x>`  | Insert | Clear AI suggestions            |

## General Editing

| Shortcut     | Mode          | Description                                         |
| ------------ | ------------- | --------------------------------------------------- |
| `<Space>`    | Normal/Visual | Leader key                                          |
| `<C-s>`      | Normal        | Save file                                           |
| `<leader>sn` | Normal        | Save file without auto-formatting                   |
| `<C-q>`      | Normal        | Quit file                                           |
| `x`          | Normal        | Delete single character without copying to register |
| `<C-d>`      | Normal        | Vertical scroll down and center                     |
| `<C-u>`      | Normal        | Vertical scroll up and center                       |
| `n`          | Normal        | Find next and center                                |
| `N`          | Normal        | Find previous and center                            |
| `<Up>`       | Normal        | Resize window - decrease height                     |
| `<Down>`     | Normal        | Resize window - increase height                     |
| `<Left>`     | Normal        | Resize window - decrease width                      |
| `<Right>`    | Normal        | Resize window - increase width                      |

## Buffer Management

| Shortcut     | Mode   | Description     |
| ------------ | ------ | --------------- |
| `<S-l>`      | Normal | Next buffer     |
| `<S-h>`      | Normal | Previous buffer |
| `<leader>bd` | Normal | Close buffer    |
| `<leader>bn` | Normal | New buffer      |

## Window Management

| Shortcut     | Mode   | Description                             |
| ------------ | ------ | --------------------------------------- |
| `<leader>v`  | Normal | Split window vertically                 |
| `<leader>h`  | Normal | Split window horizontally               |
| `<leader>se` | Normal | Make split windows equal width & height |
| `<leader>xs` | Normal | Close current split window              |
| `<C-k>`      | Normal | Navigate to window above                |
| `<C-j>`      | Normal | Navigate to window below                |
| `<C-h>`      | Normal | Navigate to window left                 |
| `<C-l>`      | Normal | Navigate to window right                |

## Tab Management

| Shortcut     | Mode   | Description        |
| ------------ | ------ | ------------------ |
| `<leader>to` | Normal | Open new tab       |
| `<leader>tx` | Normal | Close current tab  |
| `<leader>tn` | Normal | Go to next tab     |
| `<leader>tp` | Normal | Go to previous tab |

## Display Options

| Shortcut     | Mode   | Description          |
| ------------ | ------ | -------------------- |
| `<leader>lw` | Normal | Toggle line wrapping |

## Visual Mode Enhancements

| Shortcut | Mode   | Description                             |
| -------- | ------ | --------------------------------------- |
| `<`      | Visual | Decrease indent and stay in indent mode |
| `>`      | Visual | Increase indent and stay in indent mode |
| `p`      | Visual | Paste without overwriting register      |

## Text Objects

Treesitter-backed, so they work with single quotes, double quotes, backticks,
f-strings and multi-line strings alike. Use them after any operator: `vaq`,
`diq`, `ciq`, `yaq`.

| Shortcut | Mode                    | Description                                 |
| -------- | ----------------------- | ------------------------------------------- |
| `aq`     | Visual/Operator-pending | Select the whole string, quotes included    |
| `iq`     | Visual/Operator-pending | Select the string contents, without quotes  |

## Diagnostics

| Shortcut    | Mode   | Description                       |
| ----------- | ------ | --------------------------------- |
| `[d`        | Normal | Go to previous diagnostic message |
| `]d`        | Normal | Go to next diagnostic message     |
| `<leader>d` | Normal | Open floating diagnostic message  |
| `<leader>q` | Normal | Open diagnostics list             |

## Telescope (Finder)

| Shortcut           | Mode               | Description                      |
| ------------------ | ------------------ | -------------------------------- |
| `<leader>sh`       | Normal             | Search help tags                 |
| `<leader>sk`       | Normal             | Search keymaps                   |
| `<leader>sf`       | Normal             | Search files                     |
| `<leader>ss`       | Normal             | Search select Telescope          |
| `<leader>sw`       | Normal             | Search current word              |
| `<leader>sg`       | Normal             | Search by grep                   |
| `<leader>sd`       | Normal             | Search diagnostics               |
| `<leader>sr`       | Normal             | Search resume                    |
| `<leader>s.`       | Normal             | Search recent files              |
| `<leader><leader>` | Normal             | Find existing buffers            |
| `<leader>/`        | Normal             | Fuzzily search in current buffer |
| `<leader>s/`       | Normal             | Live grep in open files          |
| `<C-k>`            | Insert (Telescope) | Move to previous result          |
| `<C-j>`            | Insert (Telescope) | Move to next result              |
| `<C-l>`            | Insert (Telescope) | Open selected file               |

## LSP (Language Server Protocol)

| Shortcut     | Mode          | Description          |
| ------------ | ------------- | -------------------- |
| `gd`         | Normal        | Go to definition     |
| `gr`         | Normal        | Go to references     |
| `gI`         | Normal        | Go to implementation |
| `<leader>D`  | Normal        | Type definition      |
| `<leader>ds` | Normal        | Document symbols     |
| `<leader>ws` | Normal        | Workspace symbols    |
| `<leader>rn` | Normal        | Rename               |
| `<leader>ca` | Normal/Visual | Code action          |
| `gD`         | Normal        | Go to declaration    |
| `<leader>th` | Normal        | Toggle inlay hints   |

## Commenting

| Shortcut | Mode          | Description    |
| -------- | ------------- | -------------- |
| `<C-_>`  | Normal/Visual | Toggle comment |
| `<C-c>`  | Normal/Visual | Toggle comment |
| `<C-/>`  | Normal/Visual | Toggle comment |

## Multicursor

| Shortcut         | Mode          | Description                                      |
| ---------------- | ------------- | ------------------------------------------------ |
| `<Up>`           | Normal/Visual | Add cursor above                                 |
| `<Down>`         | Normal/Visual | Add cursor below                                 |
| `<leader><Up>`   | Normal/Visual | Skip cursor above                                |
| `<leader><Down>` | Normal/Visual | Skip cursor below                                |
| `<M-d>`          | Normal/Visual | Add cursor and match next word/selection         |
| `<M-f>`          | Normal/Visual | Skip next match of word/selection                |
| `<leader>N`      | Normal/Visual | Add cursor and match previous word/selection     |
| `<leader>S`      | Normal/Visual | Skip previous match of word/selection            |
| `<M-a>`          | Normal/Visual | Add cursors for all matches in document          |
| `<leader>mc`     | Normal        | Add cursor at current position                   |
| `ga`             | Normal        | Add cursor on each line (use with text objects)  |
| `<leader>ma`     | Normal        | Align cursor columns                             |
| `<leader>md`     | Normal/Visual | Duplicate cursors                                |
| `<leader>gv`     | Normal        | Restore cursors if accidentally cleared          |
| `<C-LeftMouse>`  | Normal        | Add/remove cursor with mouse                     |
| `<C-q>`          | Normal/Visual | Toggle cursors (disable/enable)                  |
| `<Left>`         | Normal/Visual | Select previous cursor (when multicursor active) |
| `<Right>`        | Normal/Visual | Select next cursor (when multicursor active)     |
| `<leader>x`      | Normal/Visual | Delete main cursor (when multicursor active)     |
| `<Esc>`          | Normal        | Clear all cursors or enable if disabled          |

To use advanced multicursor actions like aligning cursors, transposing text, or incrementing sequences, you can add these additional keymaps to your multicursor configuration.

## Additional Features

- **Git integration** with vim-fugitive and vim-rhubarb
- **Auto pairs** for automatic closing of parentheses, brackets, etc.
- **Todo comments** highlighting
- **Colorizer** for highlighting color codes
- **Tmux navigator** for seamless navigation between tmux and vim panes
- **Auto detect** tabstop and shiftwidth with vim-sleuth

## Notes

1. Leader key is set to Space (`<Space>`)
2. Some shortcuts may only be available when certain plugins are active
3. Multicursor functionality allows for simultaneous editing at multiple cursor positions
4. LSP shortcuts are only available when language servers are configured for the current file type
