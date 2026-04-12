#!/bin/bash

LIVEUSER="live"
chmor -R 777 ~/.config/nyarch
chmod -R 777 ~/.local/share/gnome-shell/extensions
xdg-mime default org.gnome.Nautilus.desktop inode/directory
if [ "$USER" = "$LIVEUSER" ]; then
   sleep 2
   sh -c "pkexec calamares"
else
    nyarchtourqt
    rm -rf ~/.config/autostart/start.desktop
fi

