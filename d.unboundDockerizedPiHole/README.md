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

## Package Installations and Configurations
### Docker
### Unbound
## PiHole
## Unbound
# Challenges

Sys vs diskless
Forgot keyboard - overlay; enable dhcp on ethernet, and maybe even wifi, checking unbound status

## Resources
- [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- [Alpine Linux Foundation image downloads](https://alpinelinux.org/downloads/)
- 

