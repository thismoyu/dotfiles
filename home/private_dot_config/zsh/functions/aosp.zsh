# AOSP / Android 开发工作流

goroot() {
  local target_path="${1:-$PWD}"
  case "$target_path" in
    /*) ;;
    *) target_path="$PWD/$target_path" ;;
  esac

  local tmp_path="${target_path}/"
  case "$tmp_path" in
    */alps/*)
      local remain="${tmp_path##*/alps/}"
      local alps_dir="${tmp_path%"$remain"}"
      alps_dir="${alps_dir%/}"
      if [[ -d "$alps_dir" ]]; then
        cd "$alps_dir" || return
        echo "已切换到: $PWD"
      else
        echo "错误: 目录 $alps_dir 不存在！"
        return 1
      fi
      ;;
    *)
      echo "错误: 路径 [$target_path] 中未找到名为 'alps' 的目录！"
      return 1
      ;;
  esac
}

gorepo() {
  local target_path="${1:-$PWD}"
  case "$target_path" in
    /*) ;;
    *) target_path="$PWD/$target_path" ;;
  esac

  local tmp_path="${target_path}/"
  case "$tmp_path" in
    */alps/*)
      local repo_dir="${tmp_path%/alps/*}"
      [[ -z "$repo_dir" ]] && repo_dir="/"
      if [[ -d "$repo_dir" ]]; then
        cd "$repo_dir" || return
        echo "已切换到 Repo 根目录: $PWD"
      else
        echo "错误: 父目录 $repo_dir 不存在！"
        return 1
      fi
      ;;
    *)
      echo "错误: 路径 [$target_path] 中未找到名为 'alps' 的目录！"
      return 1
      ;;
  esac
}

bootloader_unlock() {
  if ! adb devices -l | grep "device" | grep -q "product:"; then
    echo "No device connected. Please connect the device to proceed to unlocking android device. 😢"
    return 1
  fi
  echo "[+] Attempting to unlock the bootloader using fastboot. Please wait..."

  adb reboot-bootloader
  fastboot flashing unlock

  if ! fastboot getvar unlocked 2>&1 | grep -qiE "(unlocked:\s*yes|unlocked:\s*true)"; then
    echo "[!] Device bootloader unlocking failed or timed out. Rebooting... 😢"
    fastboot reboot
    return 1
  fi

  echo "[+] Device bootloader unlocking successful. Rebooting...👏"
  sleep 1
  fastboot reboot
}

adbunlock() {
  bootloader_unlock || return 1

  _wait_and_root() {
    adb wait-for-device
    sleep 3
    adb root
    sleep 2
    adb wait-for-device
  }

  _wait_and_root
  adb disable-verity
  adb reboot
  _wait_and_root
  adb remount

  echo "[+] adb remount unlock done! 👏"
}

adbshot() {
  local raw_output
  raw_output=$(adb shell dumpsys SurfaceFlinger --display-id 2>/dev/null | tr -d '\r' | grep "^Display")
  [[ -z "$raw_output" ]] && return 1

  local display_count selected_line
  display_count=$(echo "$raw_output" | wc -l)

  if [[ "$display_count" -eq 1 ]]; then
    selected_line="$raw_output"
  else
    selected_line=$(echo "$raw_output" | fzf --height 40% --reverse --prompt="Select Display> ")
    [[ -z "$selected_line" ]] && return 1
  fi

  local display_id
  display_id=$(echo "$selected_line" | awk '{print $2}')
  [[ -z "$display_id" ]] && { echo "Error: 解析 Display ID 失败。"; return 1; }

  echo "正在截取屏幕: $display_id"

  local short_id="${display_id: -4}"
  local filename="screenshot_d${short_id}_$(date +%Y%m%d_%H%M%S).png"

  adb shell screencap -p -d "$display_id" "/sdcard/$filename"
  adb pull "/sdcard/$filename" /tmp/
  adb shell rm "/sdcard/$filename"

  echo "Saved to /tmp/$filename"
}
