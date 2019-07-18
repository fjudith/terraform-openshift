#!/bin/bash -e

DATABASEDEVICE=$(readlink -f /dev/disk/by-id/google-*database*)
BACKUPDEVICE=$(readlink -f /dev/disk/by-id/google-*backup*)
DATABASEDIR="/var/lib/origin/openshift.local.volumes"
BACKUPDIR="/var/lib/docker"

for device in ${DATABASEDEVICE} ${BACKUPDEVICE}
do
  if [ "$(sudo blkid -s TYPE -o value ${device})" != "xfs" ]; then
    sudo mkfs.xfs -f ${device}
  fi
done

for dir in ${DATABASEDIR} ${BACKUPDIR}
do
  sudo mkdir -p ${dir}
  sudo restorecon -R ${dir}
done

sudo echo UUID=$(sudo blkid -s UUID -o value ${DATABASEDEVICE}) ${DATABASEDIR} xfs defaults,discard,gquota 0 2 | sudo tee -a /etc/fstab
sudo echo UUID=$(sudo blkid -s UUID -o value ${BACKUPDEVICE}) ${BACKUPDIR} xfs defaults,discard 0 2 | sudo tee -a /etc/fstab

sudo mount -a