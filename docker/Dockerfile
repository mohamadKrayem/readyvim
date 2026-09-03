# Throwaway container to test the dotfiles (nvim + tmux + lazygit + yazi)
# without touching your real machine.
#
#   docker build -f docker/Dockerfile -t dotfiles-test .
#   docker run -it --rm dotfiles-test
#
# You land in a themed tmux session with everything wired up; type `nvim`.
# debian-slim keeps the image small while staying glibc-based, so the official
# Neovim release tarball runs as-is (musl/Alpine would not).
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm-256color

# ── System dependencies (mirror the repo's Requirements table) ──────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git unzip tar gzip \
      build-essential \
      ripgrep fd-find \
      tmux \
      nodejs npm \
      python3 python3-venv python3-pip \
      xclip \
      locales \
    && sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen && locale-gen \
    && ln -sf "$(command -v fdfind)" /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

# ── Neovim (official stable release, architecture-aware) ────────────────────
RUN set -eux; \
    case "$(dpkg --print-architecture)" in \
      amd64) nvim_arch=x86_64 ;; \
      arm64) nvim_arch=arm64 ;; \
      *) echo "unsupported arch" >&2; exit 1 ;; \
    esac; \
    curl -fL "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-${nvim_arch}.tar.gz" -o /tmp/nvim.tar.gz; \
    tar -C /opt -xzf /tmp/nvim.tar.gz; \
    ln -s "/opt/nvim-linux-${nvim_arch}/bin/nvim" /usr/local/bin/nvim; \
    rm /tmp/nvim.tar.gz; \
    nvim --version | head -1

# ── lazygit (latest release, architecture-aware) ───────────────────────────
RUN set -eux; \
    case "$(dpkg --print-architecture)" in \
      amd64) lg_arch=x86_64 ;; arm64) lg_arch=arm64 ;; \
    esac; \
    ver="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -oP '"tag_name":\s*"v\K[^"]+')"; \
    curl -fL "https://github.com/jesseduffield/lazygit/releases/download/v${ver}/lazygit_${ver}_Linux_${lg_arch}.tar.gz" -o /tmp/lazygit.tar.gz; \
    tar -C /usr/local/bin -xzf /tmp/lazygit.tar.gz lazygit; \
    rm /tmp/lazygit.tar.gz

# ── yazi (latest release, architecture-aware) ──────────────────────────────
RUN set -eux; \
    case "$(dpkg --print-architecture)" in \
      amd64) yz_arch=x86_64 ;; arm64) yz_arch=aarch64 ;; \
    esac; \
    curl -fL "https://github.com/sxyazi/yazi/releases/latest/download/yazi-${yz_arch}-unknown-linux-gnu.zip" -o /tmp/yazi.zip; \
    unzip -q /tmp/yazi.zip -d /tmp/yazi; \
    mv /tmp/yazi/*/yazi /tmp/yazi/*/ya /usr/local/bin/; \
    rm -rf /tmp/yazi /tmp/yazi.zip

# ── Non-root user (closer to a real setup; Mason prefers non-root) ──────────
RUN useradd -ms /bin/bash dev
USER dev
WORKDIR /home/dev

# ── Bring in the dotfiles and symlink them exactly like a real install ──────
COPY --chown=dev:dev . /home/dev/personal/dotfiles
RUN /home/dev/personal/dotfiles/install.sh

# ── Pre-warm: install plugins + compile treesitter parsers at build time ────
# (Language servers / debug adapters install via Mason on first real launch.)
RUN nvim --headless "+Lazy! sync" +qa 2>/dev/null || true; \
    nvim --headless "+TSUpdateSync" +qa 2>/dev/null || true

# Land in a themed tmux session. `nvim` is on PATH; the whole setup is live.
CMD ["tmux", "new-session"]
