#!/bin/bash

LIVEUSER="live"
chmod -R 777 ~/.config/autostart
chmod -R 777 ~/.config/nyarch
chmod -R 777 ~/.local/share/gnome-shell/extensions
if [ "$USER" = "$LIVEUSER" ]; then
   # Disable suspension
   gsettings set org.gnome.desktop.session idle-delay "uint32 0"
   gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing"
   gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing"
   sleep 2
   sh -c "pkexec calamares"
else
    flatpak run moe.nyarchlinux.tour
    rm -rf ~/.config/autostart/start.desktop
fi

