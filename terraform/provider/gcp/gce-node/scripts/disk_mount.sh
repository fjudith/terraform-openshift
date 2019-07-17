#!/bin/bash -e

LOCALVOLDEVICE=$(readlink -f /dev/disk/by-id/google-*local*)
CONTAINERSDEVICE=$(readlink -f /dev/disk/by-id/google-*containers*)
LOCALDIR="/var/lib/origin/openshift.local.volumes"
CONTAINERSDIR="/var/lib/docker"

for device in ${LOCALVOLDEVICE} ${CONTAINERSDEVICE}
do
  if [ "$(sudo blkid -s TYPE -o value ${device})" != "xfs" ]; then
    sudo mkfs.xfs -f ${device}
  fi
done

for dir in ${LOCALDIR} ${CONTAINERSDIR}
do
  sudo mkdir -p ${dir}
  sudo restorecon -R ${dir}
done

sudo echo UUID=$(sudo blkid -s UUID -o value ${LOCALVOLDEVICE}) ${LOCALDIR} xfs defaults,discard,gquota 0 2 | sudo tee -a /etc/fstab
sudo echo UUID=$(sudo blkid -s UUID -o value ${CONTAINERSDEVICE}) ${CONTAINERSDIR} xfs defaults,discard 0 2 | sudo tee -a /etc/fstab

sudo mount -a