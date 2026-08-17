# dotfiles

基于 [chezmoi](https://www.chezmoi.io/) 管理的个人配置仓库，用于在新机器上一键还原常用工具的配置。

## 功能

集中管理常用工具的 dotfiles，包括 zsh、git、helix、kitty、mpv、ssh、fastfetch、rofi、ripgrep 等，方便跨机器同步与快速部署。

## 使用

首次应用时会根据提示补全少量个人信息，之后即可正常使用。

### 自动（推荐）

在新机器上执行一条命令，自动完成安装、克隆与配置应用，并将远端切换为 ssh：

```sh
bash -c "$(curl -fsLS https://raw.githubusercontent.com/thismoyu/dotfiles/refs/heads/main/install.sh)"
```

### 手动

如需分步执行，可依次运行以下三步：

```sh
# 1. 安装 chezmoi 到 ~/.local/bin
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# 2. 用 https 协议拉取并应用配置
~/.local/bin/chezmoi init --apply https://github.com/thismoyu/dotfiles.git

# 3. 完成后将 dotfiles 仓库远端切换为 ssh，便于后续提交
~/.local/bin/chezmoi git -- remote set-url origin git@github.com:thismoyu/dotfiles.git
```

## 常用命令

```sh
chezmoi apply    # 应用最新配置
chezmoi update   # 拉取远端更新并应用
chezmoi edit     # 编辑受管理的配置
```
