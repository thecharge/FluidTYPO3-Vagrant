#!/bin/sh
# Load tmpfs mount in NFS foilders
sudo mount -a

# Return IP(s) from the VM
echo '================================='
ip addr | grep 'state UP' -A2 | grep 'inet ' | tail -n +2 | awk '{print "IP:\t"$2}'
echo '================================='
