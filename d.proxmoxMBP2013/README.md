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

apt install dkms build-essential linux-headers-generic  # build-essential often pulls generic tools
apt install wireless-tools iw wpasupplicant
apt install broadcom-sta-dkms


Add the no-subscription repo (if missing):
Create or edit the file:textnano /etc/apt/sources.list.d/pve-no-subscription.sourcesPaste this exact content (for PVE 9 / trixie):textTypes: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpgSave and exit.
If the keyring file is missing (rare, but check with ls /usr/share/keyrings/proxmox*):textwget https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-trixie.gpg(Or use the no-sub key if needed; the above usually works.)

Disable enterprise repo if it's causing conflicts (common default install issue):textnano /etc/apt/sources.list.d/pve-enterprise.sourcesComment out the whole block by adding # to each line, or add Enabled: no under the existing entry.
