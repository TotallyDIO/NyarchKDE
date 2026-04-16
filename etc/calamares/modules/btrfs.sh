#!/bin/bash


if (disk -l | grep "sda") != ""; then

    #if [sudo btrfs check --readonly --force /dev/nvme0n1p2 | grep "WARNING" ]
    echo "123"
fi