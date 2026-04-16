#!/bin/bash


if command -v fdisk -l | grep "sda" != "" &>/dev/null; then

    #if [sudo btrfs check --readonly --force /dev/nvme0n1p2 | grep "WARNING" ]
    echo "SDA disk"
elif command -v fdisk -l | grep "nvme" != "" &>/dev/null; then
    echo "NVME disk"
elif command -v fdisk -l | grep "sr" != "" &>/dev/null; then
    echo "SR Drive"
fi