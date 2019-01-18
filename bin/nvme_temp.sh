/usr/sbin/nvme smart-log /dev/nvme0  | grep "^temperature" | awk -F: '{print $2}' | awk '{print $1}'


