#!/bin/bash
echo "Starting backup"
exec 1> >(logger -s -t backup_etc) 2>&1
borg create --v --stats --list borguser@192.168.1.201:/var/backup/{{ inventory_hostname  }}/::"etc-{now:%Y-%m-%d_%H:%M:%S}" /etc
echo "Pruning repository"
borg prune --list --keep-daily 90 --keep-monthly 12.

