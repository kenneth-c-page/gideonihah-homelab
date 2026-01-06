Date Started: January 28, 2025
# Summary

Implements Pi-Hole v6 in a Docker container on a Raspberry Pi 5 Alpine Linux machine. Includes changes to support the Unbound package and Unbound functionality, and accessing the Pi-Hole from outside of your home network.

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
To check that Docker is running:
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
## Coming Soon: Accessing the Pi-Hole oustide of Your Home Network
# Challenges

## Diskless vs System Disk

I initially attempted to run Alpine Linux on the Pi in diskless mode. It is possible, but seeing that this was my first serious homelab project, my experience relevant to this was pretty minimal. So during `setup-alpine`, I chose `sys` instead of just pressing `enter`, which sets up the Pi in diskless mode, where no changes are saved to the disk unless you commit them. I ran into several problems trying to get Docker to persist across reboots, so I just ran in `sys` mode.

## Without a Keyboard or Monitor

At one point, I lost my keyboard and at that point, having a monitor is pretty useless to set this up. However, after running the `tar -xf` command, you can add an overlay that will force the Pi to automatically assume an IP address when you connect it via ethernet to your computer. You'll need an ethernet cable (and an adapter if your host machine doesn't have an ethernet port).

> [!NOTE]
> The following steps are for a Mac (in my case, an M2)

- I found this easier to run through the command line, since downloading the overlay on a Mac would automatically unzip the download, which is not supposed to happen. As such, run:
```
curl -L https://github.com/macmpi/alpine-linux-headless-bootstrap/raw/main/headless.apkovl.tar.gz | sudo tee /Volumes/PIBOOT/headless.apkovl.tar.gz > /dev/null
```

- From there, move the downloaded `.apkovl.tar.gz` file into the root directory on your SD card. This is easiest in moving it in the File Explorer, Finder, or Similar App.

> [!CAUTION]
> Don't move the zipped file into any of the directories on your SD card. It should stay at the top with everything else.

- From there, safely eject the SD card and use it to boot the pi as normal.

- After running `setup-alpine`, remove the overlay as the system's dialog suggests:
```
mount -o remount,rw /media/mmcblk0... # replace with the acutal name of the partition, usually mmcblk0p1, this lets you write to the directory (it will give you a read-only error otherwise)
rm /media/mmcblk0.../headless.apkovl.tar.gz # make sure the .tar.gz file name is the one you actually used
mount -o remount,ro /media/mmcblk0
```


## Testing the Unbound Connection
`dig` is not already included on the Pi. Add it with:
```
doas apk add bind-tools
```
Further, when trying to run the `dig` command as in Travis Media's tutorial, I ran into some complications: the Unbound connection was not exposed to anything but the Pi-Hole container. This is because the setup has the Unbound container sharing the same namesapce as the Pi-Hole. As such, only the Pi-Hole can access the Unbound container.

So, to check Unbound status from inside the Pi-Hole container, run:
```
docker exec -it pihole dig google.com @127.0.0.1 -p 5335 # make sure pihole is the actual container name for the Pi-Hole, which it should be if you used the referenced Pi-Hole image above
```

It should return output that looks like:
```
; <<>> DiG 9.20.16 <<>> google.com @127.0.0.1 -p 5335
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 53754
;; flags: qr rd ra; QUERY: 1, ANSWER: 6, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		300	IN	A	142.251.108.138
google.com.		300	IN	A	142.251.108.100
google.com.		300	IN	A	142.251.108.101
google.com.		300	IN	A	142.251.108.113
google.com.		300	IN	A	142.251.108.102
google.com.		300	IN	A	142.251.108.139

;; Query time: 11 msec
;; SERVER: 127.0.0.1#5335(127.0.0.1) (UDP)
;; WHEN: <DATE AND TIME HERE>
;; MSG SIZE  rcvd: 135
```

## Resources
- [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- [Alpine Linux Foundation image downloads](https://alpinelinux.org/downloads/)
- [Official Pi-Hole Docker Image](https://hub.docker.com/r/pihole/pihole)
- [Travis Media's tutorial on how to do this](https://travis.media/blog/pihole-v6-unbound-docker-compose-raspberry-pi/)
- [Official Pi-Hole Unbound `.conf` file](https://docs.pi-hole.net/guides/dns/unbound/)
