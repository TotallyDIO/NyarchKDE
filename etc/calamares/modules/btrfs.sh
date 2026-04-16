if [sudo fdisk -l | grep "nvme" != ""]; then
    #if [sudo btrfs check --readonly --force /dev/nvme0n1p2 | grep "WARNING" ]
    echo "123"
    break
echo "done"
