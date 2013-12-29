Busybox for ARM on QEMU
======================

● Prepare
------------------
이 포스트를 따라하기 위해서는 아래의 준비물이 필요합니다.

    * QEMU http://wiki.qemu.org/
    * Linux Kernel https://www.kernel.org
    * Busybox http://www.busybox.net
    * Sourcery CodeBench Lite Edition for ARM
      https://sourcery.mentor.com/sgpp/lite/arm/portal/subscription?@template=lite

아래의 명령어를 사용하여 준비물을 모두 받아주세요.

$ git clone https://github.com/leekyuhyuk/qemu_linux_arm_busybox.git

● Bulid QEMU
------------------
빌드하기 전에 아래의 패키지를 설치해주세요.

$ sudo apt-get install build-essential autoconf libtool zlib1g-dev

qemu-1.7.0 폴더로 이동하고 아래와 같이 입력하여 빌드 합니다.

    $ cd qemu-1.7.0
    $ ./configure --prefix=빌드한 qemu가 저장될 경로
    $ make -j16
    $ make install
위의 명령어를 입력하면 configure에서 설정한 경로에 qemu가 생성됩니다.


$ qemu-system-arm --version 으로 확인해봅니다.

(저는 qemu-1.7.0 폴더에 install 폴더를 만들었기 때문에 ./install/bin/qemu-system-arm --version 명령어를 입력하였습니다)


● Build Linux Kernel
------------------
빌드하기 전에 아래의 패키지를 설치합니다.

$ sudo apt-get install build-essential bin86 kernel-package libncurses5-dev


아래의 명령어로 환경을 설정해줍니다.

$ source envsetup.sh 


Linux Kernel 소스가 저장되어 있는곳으로 이동한뒤 아래와 같이 명령합니다.

    $ cd linux-3.12.6
    $ make versatile_defconfig
    $ make menuconfig


그러면 아래와 같이 Linux Kernel Configuration이 나오게 됩니다.

여기서 Enable loadable module support 옆에 [*]를 없애줍니다.

General setup안에 Automatically append version information to the version string라는게 있는데 [*] 해줍니다.

또 Kernel Features에 들어가면 Use the ARM EABI to compile the kernel라는 것도 있는데 [*] 해줍니다.


설정을 다했다면 make 명령어로 커널을 빌드합니다.

    $ make


빌드가 완료되면 arch/arm/boot에 저장됩니다.

    $ ./qemu-system-arm -M versatilepb -m 128M -kernel linux-3.12.6/arch/arm/boot/zImage -serial stdio



● Bulid Busybox
------------------

    $ cd busybox-1.21.1
    $ make defconfig
    $ make menuconfig
Busybox Settings - Build Options에 들어갑니다.

Build BusyBox as a static binary (no shared libs)를 [*]하고, Cross Compiler prefix에 arm-none-linux-gnueabi- 를 입력해줍니다.

설정을 마치고 빌드를 합니다.

    $ make
    $ make install
빌드된 파일들은 _install 폴더에 저장이 됩니다.

_initall로 이동하여 Root File System을 만듭니다.

    $ cd _install
    $ find . | cpio -o --format=newc > ../rootfs.img
    $ cd ..
    $ gzip -c rootfs.img > rootfs.img.gz

● Run
------------------

    ./qemu-system-arm -M versatilepb -m 128M -kernel linux-3.12.6/arch/arm/boot/zImage
      -initrd busybox-1.21.1/rootfs.img.gz -append "root=/dev/ram rdinit=/bin/sh" -serial stdio


● Use /sbin/init
------------------
위에 명령어로 부팅될때는 /bin/sh를 실행하게 되는데 rdinit안의 내용을 바꾸면 어떻게 될까요?

rdinit=/sbin/init로 바꾸게 되면 /sbin/init를 실행하게 됩니다.

여기서 /sbin/init는 Linux kernel로 부터 처음 실행될 때 사용됩니다. 나머지 부트 프로세스를 주관하며 사용자를 위한 환경을 설정합니다. 그리고 /etc/init.d/rcS를 가장 먼저 실행하게 됩니다.

    $ cd busybox-1.21.1/_install
    $ mkdir proc sys dev etc etc/init.d
    $ vi etc/init.d/rcS
      #!/bin/sh
      mount -t proc none /proc
      mount -t sysfs none /sys
      /sbin/mdev -s
      
    $ chmod +x etc/init.d/rcS
    $ find . | cpio -o --format=newc > ../rootfs.img
    $ cd ..
    $ gzip -c rootfs.img > rootfs.img.gz
    $./qemu-system-arm -M versatilepb -m 128M -kernel linux-3.12.6/arch/arm/boot/zImage
      -initrd busybox-1.21.1/rootfs.img.gz -append "root=/dev/ram rdinit=/sbin/init" -serial stdio
