#!/bin/bash

NVME=F


# Checks for partitions
if command -v sudo fdisk -l | grep "nvme" == "" &>/dev/null; then
    echo "123"
fi




echo "end"