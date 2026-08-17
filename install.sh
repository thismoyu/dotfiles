#!/usr/bin/env sh
# shellcheck disable=SC3043 # `local` is supported by every real /bin/sh.

set -o errexit -o nounset

ensure_chezmoi() {
	local chezmoi

	if chezmoi="$(command -v chezmoi)"; then
		printf '%s\n' "${chezmoi}"
		return 0
	fi

	local bin_dir="${HOME}/.local/bin"
	chezmoi="${bin_dir}/chezmoi"

	printf 'Installing chezmoi to %s\n' "${chezmoi}" >&2

	if ! command -v curl >/dev/null; then
		printf 'To install chezmoi, you must have curl installed.\n' >&2
		exit 1
	fi

	local chezmoi_install_script
	chezmoi_install_script="$(
		curl \
			--fail \
			--silent \
			--show-error \
			--location \
			--proto '=https' \
			https://get.chezmoi.io
	)"
	sh -c "${chezmoi_install_script}" -- -b "${bin_dir}" >&2

	printf '%s\n' "${chezmoi}"
}

main() {
	local chezmoi
	chezmoi="$(ensure_chezmoi)"

	local repo_https="https://github.com/thismoyu/dotfiles.git"
	local repo_ssh="git@github.com:thismoyu/dotfiles.git"

	# 用 https 协议克隆并应用配置(新机器无 ssh key 也能拉取)
	printf "Running 'chezmoi init --apply %s'\n" "${repo_https}" >&2
	"${chezmoi}" init --apply "${repo_https}"

	# 完成后将 dotfiles 仓库远端切换为 ssh,便于后续提交
	printf "Switching origin remote to %s\n" "${repo_ssh}" >&2
	"${chezmoi}" git -- remote set-url origin "${repo_ssh}"
}

main "$@"
