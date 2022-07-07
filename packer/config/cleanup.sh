#!/bin/bash

# remove subscriptions
if subscription-manager status
then
        subscription-manager unsubscribe --all
        subscription-manager unregister
fi

subscription-manager clean

# clean out /tmp
find /tmp -mindepth 1 -delete

rm -f /etc/machine-id

systemctl status systemd-udevd && systemctl -q stop systemd-udevd

# Remove auto-generated udev rules for CD-ROM and network devices
rm -f /etc/udev/rules.d/70-persistent-{cd,net}.rules

# unset the hostname
hostnamectl set-hostname localhost.localdomain

# Zero out the rest of the free space using dd, then delete the written file.
echo "Writing zeroes to free space (this could take a while)."
dd if=/dev/zero of=/EMPTY bs=1M 2> /dev/null
rm -f /EMPTY

# Add `sync` so Packer doesn't quit too early, before the large file is deleted.
sync

echo "Cleanup done."
