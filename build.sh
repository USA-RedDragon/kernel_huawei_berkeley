#!/bin/bash

export kernel=Werewolf
export outdir=/home/reddragon/Werewolf
export makeopts="-j$(nproc)"
export zImagePath="build/arch/arm64/boot/Image.gz"
export KBUILD_BUILD_USER=USA-RedDragon
export KBUILD_BUILD_HOST=EdgeOfEternity
export CROSS_COMPILE="ccache /home/reddragon/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
export ARCH=arm64
export shouldclean="0"
export istest="0"
export deviceconfig="werewolf_defconfig"
export device="berkeley"
export modules="0"

export OS_VERSION=8.1.0
export PATCH_LEVEL=2018-03-01

export KERNEL_CMDLINE="loglevel=4 initcall_debug=n page_tracker=on unmovable_isolate1=2:192M,3:224M,4:256M printktimer=0xfff0a000,0x534,0x538 androidboot.selinux=enforcing buildvariant=user"
export BASE=0x0
export PAGESIZE=2048
export KERNEL_OFFSET=0x00080000
export RAMDISK_OFFSET=0x07C00000
export TAGS_OFFSET=0x07A00000

export version=$(cat version)

function build() {
    if [[ $shouldclean =~ "1" ]] ; then
        rm -rf build
    fi

    mkdir -p build

    make O=build ${makeopts} ${deviceconfig}
    make O=build ${makeopts}

    if [ ! -e ${zImagePath} ] ; then
        echo -e "\n\e[31m***** Build Failed *****\e[0m\n"
    fi

    if ! [ -d ${outdir} ] ; then
        mkdir ${outdir}
    fi

    ./tools/mkbootimg --kernel ${zImagePath} --base ${BASE} --cmdline "${KERNEL_CMDLINE}" --tags_offset ${TAGS_OFFSET} --kernel_offset ${KERNEL_OFFSET} --ramdisk_offset ${RAMDISK_OFFSET} --os_version ${OS_VERSION} --os_patch_level ${PATCH_LEVEL}  --output ${outdir}/Werewolf-${device}-${version}.img

    if [ ! -e ${outdir}/Werewolf-${device}-${version}.img ] ; then
        echo -e "\n\e[32m***** Build Finished: ${outdir}/Werewolf-${device}-${version}.img *****\e[0m\n"
    fi

}

if [[ $1 =~ "clean" ]] ; then
    shouldclean="1"
fi

build
