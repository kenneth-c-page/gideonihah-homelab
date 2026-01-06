Date Started: January 28, 2025
# Summary

Implements Pi-Hole v6 in a Docker container on a Raspberry Pi 5 Alpine Linux machine. Includes changes to support the Unbound package and Unbound functionality.

# Process
## Alpine Linux

The Raspberry Pi 5 can run Alpine Linux through the image available on the [official Raspberry Pi Imager](https://www.raspberrypi.com/software/), or the image that the Alpine Linux Foundation [provides](https://alpinelinux.org/downloads/). The image used in this setup was the `.tar` download for the steps explained in the ['Challenges' section](#Challenges).

> [!NOTE]
> If you used the official Raspberry Pi Imager, you can skip these next steps, as they pertain to using the download from the Alpine Linux Foundation's website.

Download the more recent `.tar` image for `aarch64` (for newer Raspberry Pi models) and insert the SD card you'll format into your computer or adapter. Format the card as `FAT32` (also `MS-DOS FAT`).

> [!NOTE]
> Sometimes, the download may automatically unzip. This requires a slightly different command to image the SD card:
```
tar -xf /Path/To-The-Downloaded-Image/name-of-the-pi-image.tar -C /Volumes/SDCARDNAMEHERE/
```
Replace `/Path/To-The-Downloaded-Image/` with the actual path to the image you downloaded, `name-of-the-pi-image.tar` with the actual name of the image you downloaded, and `/Volumes/SDCARDNAMEHERE/` with the path to and name of the SD card.

If the file didn't automatically unzip, run the following command with the same changes described just above:
```
tar -xfz /Path/To-The-Downloaded-Image/name-of-the-pi-image.tar -C /Volumes/SDCARDNAMEHERE/
```

From here, insert and use the SD card to boot the Raspberry Pi as normal.

After booting the Pi, (preferably) run setup-alpine. The steps of note I followed included:
- Setting up ethernet (`eth0`) to dhcp (especially useful if running headless and sharing internet over ethernet)
- Setting up WiFi
- Creating another user
- Setting up ssh with sshd
And finally, when you reach the point if it asks to run from the disk (usually `mmcblk0...` or the like:
- Choose `yes`
- Type in the disk's name (usually `mmcblk0p1`)
- And select `sys` when you get to that option—this makes changes persistent and is very useful
- Reboot when it finishes syncing the disk

## Package Installations and Configurations

Regarding configurations to the above setup and services, I didn't change much. I wouldn't even allow ssh as root, and instead ssh in as the user you created and switch users to root after you've logged in.

### doas

Alpine recommends using `doas` instead of `sudo`, which is what I did. As root:
```
apk update
apk add doas
addgroup <Insert the name of the user you created here> wheel
```

To check that the user is now in `wheel`, run:
```
groups <Insert the name of the user you created here>
```

Then allow the wheel group to use `doas`:
```
echo 'permit persist :wheel' > /etc/doas.d/20-wheel.conf
```

### Docker

From the user that you created, run:
```
doas apk update
doas apk add docker docker-cli-compose
addgroup <Insert user name here> docker
rc-update add docker boot # or default
rc-service docker start
```
To check that docker is running:
```
service docker status # should show '*started'
docker version
```

### Unbound

From the user that you created, run:
```
doas apk update
doas apk add unbound
```

## PiHole
## Unbound
# Challenges

Sys vs diskless
Forgot keyboard - overlay; enable dhcp on ethernet, and maybe even wifi, checking unbound status

## Resources
- [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- [Alpine Linux Foundation image downloads](https://alpinelinux.org/downloads/)
- 


