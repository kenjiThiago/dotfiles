if [[ "$(tty)" == "/dev/tty1" ]]; then
    if uwsm check may-start > /dev/null 2>&1; then
        exec uwsm start hyprland.desktop
    fi
fi
