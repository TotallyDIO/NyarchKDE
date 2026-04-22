#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="nyarch-kde"
iso_label="NYARCH-NVIDIA-KDE_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%y%m%d)"
iso_publisher="Nyarch Linux <https://nyarchlinux.moe>"
iso_application="NyarchLinux DVD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%y%m%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.grub')
pacman_conf="./pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-b' '1M')
bootstrap_tarball_compression=(zstd)
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/etc/sudoers"]="0:0:440"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/bin/ezmaint"]="0:0:755"
  ["/usr/local/bin/grubinstall.sh"]="0:0:755"
  ["/usr/local/bin/nyarch.bios"]="0:0:755"
  ["/usr/local/bin/nyarch.uefi"]="0:0:755"
  ["/usr/local/bin/nekofetch"]="0:0:755"
  ["/usr/local/bin/nyaofetch"]="0:0:755"
  ["/usr/local/bin/nyay"]="0:0:755"
  ["/usr/share/nyarcher/Scripts/autostart.sh"]="0:0:755"
  ["/usr/share/nyarcher/Scripts/cheange_wallpaper.sh"]="0:0:755"
)
