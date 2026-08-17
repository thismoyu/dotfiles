#!/usr/bin/env bash
# =============================================================================
# Chezmoi Script: Switch origin remote to SSH
# =============================================================================
# After the initial https clone/apply, point the dotfiles repo's origin remote
# at the SSH URL so future commits/pushes use the SSH key. Idempotent: skips if
# origin is already the SSH URL.

set -eufo pipefail

git -C "${CHEZMOI_WORKING_TREE}" remote set-url origin git@github.com:thismoyu/dotfiles.git