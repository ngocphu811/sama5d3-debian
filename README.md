##Debian Linux for Atmel SAMA5D3

Project consists of collected up info partly based on [ACME Acqua A5](http://www.acmesystems.it/acqua) instructions to configure Debian Linux on a SAMA5D3x.  The Atmel Xplained kit was used for development which has SAMA5D36 CPU model.  For the testing Linux loads from SD Card and the **nand CS jumper is removed**.

####References useful.

- [Building bootloader](http://www.at91.com/linux4sam/bin/view/Linux4SAM/AT91Bootstrap)
- [Building kernel](http://www.at91.com/linux4sam/bin/view/Linux4SAM/LinuxKernel)
- [Building rootfs](http://www.acmesystems.it/emdebian_grip_armhf)

####Development system based on Xubuntu 14.04

```sh
    sudo apt-get install synaptic gedit gparted
    sudo apt-get install build-essential bison flex texinfo
```

####Configure git.

```sh
    sudo apt-get install git
    git config --global user.name $USER
    git config --global user.email $USER_EMAIL
```

####Setting up for ARM cross development.

```sh
    sudo apt-get install gcc-4.8-arm-linux-gnueabihf binutils-arm-linux-gnueabihf
    # TODO wildcard this simlink operation...
    sudo ln -T arm-linux-gnueabihf-cpp-4.8 arm-linux-gnueabihf-cpp
    sudo ln -T arm-linux-gnueabihf-g++-4.8 arm-linux-gnueabihf-g++
    sudo ln -T arm-linux-gnueabihf-gcc-4.8 arm-linux-gnueabihf-gcc
    sudo ln -T arm-linux-gnueabihf-gcc-ar-4.8 arm-linux-gnueabihf-gcc-ar
    sudo ln -T arm-linux-gnueabihf-gcc-nm-4.8 arm-linux-gnueabihf-gcc-nm
    sudo ln -T arm-linux-gnueabihf-gcc-ranlib-4.8 arm-linux-gnueabihf-gcc-ranlib
    sudo ln -T arm-linux-gnueabihf-gcov-4.8 arm-linux-gnueabihf-gcov
```

```sh
    sudo apt-get install qemu
    sudo apt-get install qemu-user-static
    sudo apt-get install binfmt-support
    sudo apt-get install dpkg-cross
```

```sh
    sudo apt-get install multistrap
    # to resolve error must fix line #989 by deleting $forceyes
    sudo gedit /usr/sbin/multistrap
```

##Creating SD Card

```sh
    mkdir $PROJECT_ROOT
    cd $PROJECT_ROOT
```

####Build Atmel boot loader.

```sh
    git clone git://github.com/linux4sam/at91bootstrap.git
    cd at*
    make mrproper
    make sama5d3_xplainedsd_linux_zimage_dt_defconfig
    make CROSS_COMPILE=/usr/bin/arm-linux-gnueabihf-
    cd ..
```

####Build Atmel kernel.

```sh
    git clone git://github.com/linux4sam/linux-at91.git
    cd linux*
    make ARCH=arm sama5_xplained_defconfig
    make ARCH=arm CROSS_COMPILE=/usr/bin/arm-linux-gnueabihf- zImage
    make ARCH=arm CROSS_COMPILE=/usr/bin/arm-linux-gnueabihf- dtbs
    cd ..
```

####Debian root file system.

```sh
    sudo multistrap -f rootfs.conf
    sudo mkdir rootfs/dev/pts
    sudo mknod rootfs/dev/random c 1 8
    sudo mknod rootfs/dev/urandom c 1 9
    sudo mknod rootfs/dev/ptmx c 5 2
    sudo mknod rootfs/dev/null c 1 3
    sudo cp /usr/bin/qemu-arm-static rootfs/usr/bin
    sudo LC_ALL=C LANGUAGE=C LANG=C chroot rootfs dpkg --configure -a
    sudo ./rootfs-config.sh
    sudo chroot rootfs passwd
    sudo rm rootfs/usr/bin/qemu-arm-static
```

####Bootable SD Card.

TODO Partitioning is for temporary testing on the Xplained kit as below.

- 32M=fat=kernel
- 800M=ext4=rootfs
- 800M=ext4=data
- linux-swap=swap

####Partition kernel.

```sh
    cp at91bootstrap/binaries/sama5d3_xplained-sdcardboot-linux-zimage-dt-3.6.2.bin /media/$USER/kernel/boot.bin
    cp linux-at91/arch/arm/boot/zImage /media/$USER/kernel/
    cp linux-at91/arch/arm/boot/dts/at91-sama5d3_xplained.dtb /media/$USER/kernel/
    sync
```

####Partition rootfs.

```sh
    sudo rsync -axHAX --progress ./rootfs/ /media/$USER/rootfs/
    sync
```

####Partition data.

TBD.

