Download and etch .iso
- link balena etcher
- link iso site
Challenges:
network
plug in ethernet over usb

boot while plugged in
boot without ethernet
option
at menu plug in ethernet
select EFI
set
boot

I set pihole
make sure to use proxmox.name.local

Edit
/etc/systemd/logind.conf

Change
HandleLidSwitch to =ignore
HandleLidSwitchExternalPower to =ignore
HandleLidSwitchDocked to =ignore