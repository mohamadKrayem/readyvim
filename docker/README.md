# Testing the dotfiles in Docker

A throwaway Linux container that installs the same tools this config expects,
runs `install.sh`, and pre-installs the Neovim plugins — so you can try the whole
setup without touching your real machine.

## Quick start

```bash
# from the repo root
make docker-test
```

That builds the image and drops you into a **themed tmux session**. From there:

- type `nvim` — the config is live (first launch installs the LSPs/debug
  adapters via Mason, ~1 minute)
- `prefix + g` — lazygit in a floating popup
- `Ctrl+h/j/k/l` — move seamlessly between nvim splits and tmux panes
- `yazi` — the file manager

Exit the container with `exit` (or `Ctrl+d`). `--rm` means it leaves nothing behind.

## Without make

```bash
docker build -f docker/Dockerfile -t dotfiles-test .
docker run -it --rm dotfiles-test
```

## Iterating on the config

`make docker-dev` mounts the repo into the container, so edits you make on your
host show up immediately inside it (the symlinks point at the mounted copy):

```bash
make docker-dev
```

Edit a file in `nvim/` on your host, then reload/relaunch nvim in the container
to see the change.

## What the image contains

| Installed | How |
|-----------|-----|
| Neovim (stable) | official release tarball, arch-aware (amd64 / arm64) |
| tmux, ripgrep, fd, git | apt |
| node, python3 (+venv/pip) | apt — for the language servers & debug adapters |
| build-essential | treesitter parser compilation |
| lazygit, yazi | latest GitHub releases, arch-aware |
| language servers, DAP | Mason, on first `nvim` launch |

## Notes

- **Icons look like boxes** in the container — that's expected. The image has no
  Nerd Font, and Neovim's UI uses glyphs. Functionality is unaffected; the tmux
  side is ASCII-only so it renders fine.
- The build pre-runs `Lazy! sync` and `TSUpdateSync`, so plugins and treesitter
  parsers are baked in. Only Mason-managed binaries install on first launch.
- Works on Apple Silicon and Intel — every download picks the right architecture.
