#!/usr/bin/env bash
# Symlink these configs into the places each tool expects.
#
# Anything already at a target path is moved aside into a timestamped backup
# directory rather than overwritten. Re-running is safe.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# lazygit looks in Application Support on macOS, ~/.config elsewhere.
case "$(uname -s)" in
	Darwin) LAZYGIT_DIR="$HOME/Library/Application Support/lazygit" ;;
	*)      LAZYGIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit" ;;
esac

link() {
	local src="$1" dest="$2"

	# Already pointing where we want? nothing to do.
	if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
		printf '  ok       %s\n' "${dest/#$HOME/~}"
		return
	fi

	if [ -e "$dest" ] || [ -L "$dest" ]; then
		mkdir -p "$BACKUP/$(dirname "${dest#$HOME/}")"
		mv "$dest" "$BACKUP/${dest#$HOME/}"
		printf '  backed up %s\n' "${dest/#$HOME/~}"
	fi

	mkdir -p "$(dirname "$dest")"
	ln -s "$src" "$dest"
	printf '  linked   %s -> %s\n' "${dest/#$HOME/~}" "${src/#$HOME/~}"
}

echo "Linking dotfiles from ${DOTFILES/#$HOME/~}"
link "$DOTFILES/nvim"              "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
link "$DOTFILES/tmux/tmux.conf"    "$HOME/.tmux.conf"
link "$DOTFILES/yazi"              "${XDG_CONFIG_HOME:-$HOME/.config}/yazi"
link "$DOTFILES/lf/lfrc"           "${XDG_CONFIG_HOME:-$HOME/.config}/lf/lfrc"
link "$DOTFILES/lazygit/config.yml" "$LAZYGIT_DIR/config.yml"

if [ -d "$BACKUP" ]; then
	echo
	echo "Replaced files saved in: ${BACKUP/#$HOME/~}"
fi

echo
echo "Done. Start nvim to let lazy.nvim install plugins, then run :checkhealth."
