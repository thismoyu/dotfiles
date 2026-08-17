#!/usr/bin/env sh
#
# A rofi powered menu to execute power related action.
# Uses: amixer mpc poweroff reboot rofi rofi-prompt

power_off="' PowerOff"
reboot="' Reboot"
lock="' Lock"
log_out="  LogOut"

chosen=$(printf '%s;%s;%s;%s\n' "$power_off" "$reboot" "$lock"\
                                   "$log_out" \
    | rofi -theme-str '@import "~/.config/rofi/powermenu.rasi"' \
           -dmenu \
           -sep ';' \
           -selected-row 2)

case "$chosen" in
    "$power_off")
        rofi-prompt --query 'Shutdown?' && poweroff
        ;;

    "$reboot")
        rofi-prompt --query 'Reboot?' && reboot
        ;;

    "$lock")
        # TODO Add your lockscreen command.
        ;;

    "$log_out")
        loginctl terminate-user `whoami`
        ;;

    *) exit 1 ;;
esac
