##### Extra settings for Ubuntu running on SSD

Tested on Asus EeePC 1005PXD + Lubuntu 16.04

Move log and tmp filesystems to RAM, adding the following lines to `/etc/fstab`:
```bash
tmpfs /tmp tmpfs mode=1777 0 0
tmpfs /var/tmp tmpfs mode=1777 0 0
tmpfs /var/log tmpfs mode=0755 0 0
tmpfs /var/log/apt tmpfs defaults 0 0
```

Set swappiness to the minimum:
```bash
sudo echo "vm.swappiness=1" >> /etc/sysctl.conf
```
