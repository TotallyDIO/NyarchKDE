#!/bin/bash

LIVEUSER="live"
if [ "$USER" = "$LIVEUSER" ]; then
  echo idk
else
    nyarchtourqt
    rm -rf ~/.config/autostart/start.desktop
fi

