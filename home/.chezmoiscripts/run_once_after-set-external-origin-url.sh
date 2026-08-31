#!/usr/bin/env bash
# =============================================================================
# Chezmoi Script: Switch git-repo external remotes to SSH
# =============================================================================
# Externals are cloned via HTTPS (SSH may not be ready on first bootstrap).
# After they exist, point origin at SSH so subsequent push/pull use the key.
# Uses run_once_after_ so this runs only once. Skips missing repos.

set -eufo pipefail

set_ssh_origin() {
	local dir="$1"
	local url="$2"

	if [[ ! -d "${dir}/.git" ]]; then
		return 0
	fi

	git -C "${dir}" remote set-url origin "${url}"
}

set_ssh_origin "${HOME}/.config/nvim" git@github.com:thismoyu/nvim-config.git
set_ssh_origin "${HOME}/.local/share/fcitx5/rime" git@github.com:thismoyu/oh-my-rime.git
