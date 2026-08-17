# 通用函数

md() { mkdir -p "$@" && cd "$@"; }
mf() { touch "$@"; }

csvpreview() {
  sed 's/,,/, ,/g;s/,,/, ,/g' "$@" | column -s, -t | less -#2 -N -S
}

# 目录书签（gd）
_GD_DIR="$ZDOTDIR/jump"
_GD_LUA="$_GD_DIR/quick_jump.lua"
_GD_LIST="$_GD_DIR/quick_jump_list"

gd() {
  local opt="$1"
  if [[ "$opt" == "-a" ]]; then
    lua "$_GD_LUA" -a "$2" "$(pwd)"
  elif [[ "$opt" == "-l" ]]; then
    lua "$_GD_LUA" -l
  elif [[ "$opt" == "-e" ]]; then
    "$EDITOR" "$_GD_LIST"
  else
    local dir=$opt
    if [[ ! -d "$dir" ]]; then
      dir=$(lua "$_GD_LUA" "$dir")
    fi
    dir=$(eval echo "$dir")
    cd "$dir"
  fi
}

_gd_dir_list() {
  local gd_cmp=($(lua "$_GD_LUA" -l))
  compadd "$@" -- $gd_cmp
  _cd "$@" || compadd "$@" -- $gd_cmp
}

# 代理（GNOME / Cinnamon 桌面同步系统代理）
proxy_disable() {
  unset http_proxy https_proxy ftp_proxy all_proxy
  unset HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY
  echo "✅ 已临时关闭终端代理（环境变量已清除）"
}

proxy_check() {
  local vars=("http_proxy" "https_proxy" "ftp_proxy" "all_proxy")
  local any_set=false

  echo "=== 当前终端代理环境变量 ==="
  for var in "${vars[@]}"; do
    if [[ -n "${(P)var}" ]]; then
      echo "$var=${(P)var}"
      any_set=true
    else
      echo "$var 未设置"
    fi
  done

  echo ""

  if [[ "$any_set" == true ]]; then
    echo "正在测试代理连通性（尝试访问 http://www.google.com）..."
    if curl --proxy "${http_proxy:-${https_proxy}}" -s --head http://www.google.com | grep -q "200 OK"; then
      echo "✅ 代理连通性良好（可以访问 Google）"
    else
      echo "⚠️ 无法通过代理访问 Google，可能代理不可用或被阻止"
    fi
  else
    echo "❌ 未检测到代理环境变量，网络流量将不会走代理"
  fi
}

proxy_sync() {
  local quiet="$1"
  local mode
  mode=$(gsettings get org.gnome.system.proxy mode 2>/dev/null | tr -d "'")

  if [[ "$mode" == "none" ]]; then
    unset http_proxy https_proxy ftp_proxy all_proxy
    unset HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY
    [[ "$quiet" != "quiet" ]] && echo "系统代理已禁用"

  elif [[ "$mode" == "manual" ]]; then
    local http_host http_port https_host https_port
    http_host=$(gsettings get org.gnome.system.proxy.http host | tr -d "'")
    http_port=$(gsettings get org.gnome.system.proxy.http port)
    https_host=$(gsettings get org.gnome.system.proxy.https host | tr -d "'")
    https_port=$(gsettings get org.gnome.system.proxy.https port)

    export http_proxy="http://${http_host}:${http_port}"
    export https_proxy="http://${https_host}:${https_port}"
    export ftp_proxy="http://${http_host}:${http_port}"
    export all_proxy="http://${http_host}:${http_port}"
    export HTTP_PROXY="$http_proxy" HTTPS_PROXY="$https_proxy"
    export FTP_PROXY="$ftp_proxy" ALL_PROXY="$all_proxy"

    if [[ "$quiet" != "quiet" ]]; then
      echo "代理已设置："
      echo "HTTP: $http_proxy"
      echo "HTTPS: $https_proxy"
    fi
  else
    [[ "$quiet" != "quiet" ]] && echo "未知的代理模式或者 PAC：$mode"
  fi
}
