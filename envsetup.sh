#!/bin/sh
PATH_NAME=$(pwd)
ARCH=arm
CROSS_COMPILE=$PATH_NAME/tools/arm-2013.11/bin/arm-none-linux-gnueabi-
export PATH ARCH CROSS_COMPILE
echo ARCH=$ARCH
echo CROSS_COMPILE = $CROSS_COMPILE
