#!/bin/sh
../tools/qemu-1.7.0/bin/qemu-system-arm -M versatilepb -m 128M -kernel zImage -initrd rootfs.img.gz -append "root=/dev/ram rdinit=/sbin/init" -serial stdio
