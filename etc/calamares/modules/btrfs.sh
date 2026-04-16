#!/bin/bash


if command -v disk -l | grep "sda" != "" &>/dev/null; then

    #if [sudo btrfs check --readonly --force /dev/nvme0n1p2 | grep "WARNING" ]
    echo "123"
else
    echo "456"
fi