inherit image_types

IMAGE_ROOTFS = "${WORKDIR}/rootfs/linuxrootfs1"

do_image_hdemmc[depends] = " \
	e2fsprogs-native:do_populate_sysroot \
	parted-native:do_populate_sysroot \
	dosfstools-native:do_populate_sysroot \
	mtools-native:do_populate_sysroot \
	virtual/kernel:do_populate_sysroot \
"

EMMC_IMAGE = "${IMGDEPLOYDIR}/${IMAGE_NAME}.emmc.img"
BLOCK_SIZE = "512"
BLOCK_SECTOR = "2"
IMAGE_ROOTFS_ALIGNMENT = "1024"
BOOT_PARTITION_SIZE = "3072"
KERNEL_PARTITION_SIZE = "8192"
ROOTFS_PARTITION_SIZE = "1048576"
EMMC_IMAGE_SIZE = "3817472"

KERNEL_PARTITION_OFFSET = "$(expr ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_PARTITION_SIZE})"
ROOTFS_PARTITION_OFFSET = "$(expr ${KERNEL_PARTITION_OFFSET} \+ ${KERNEL_PARTITION_SIZE})"
SECOND_KERNEL_PARTITION_OFFSET = "$(expr ${ROOTFS_PARTITION_OFFSET} \+ ${ROOTFS_PARTITION_SIZE})"
THRID_KERNEL_PARTITION_OFFSET = "$(expr ${SECOND_KERNEL_PARTITION_OFFSET} \+ ${KERNEL_PARTITION_SIZE})"
FOURTH_KERNEL_PARTITION_OFFSET = "$(expr ${THRID_KERNEL_PARTITION_OFFSET} \+ ${KERNEL_PARTITION_SIZE})"
MULTI_ROOTFS_PARTITION_OFFSET = "$(expr ${FOURTH_KERNEL_PARTITION_OFFSET} \+ ${KERNEL_PARTITION_SIZE})"

IMAGE_CMD_hdemmc () {
    eval local COUNT=\"0\"
    eval local MIN_COUNT=\"60\"
    if [ $ROOTFS_SIZE -lt $MIN_COUNT ]; then
        eval COUNT=\"$MIN_COUNT\"
    fi
    dd if=/dev/zero of=${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext4 seek=${IMAGE_ROOTFS_SIZE} count=$COUNT bs=1024
    mkfs.ext4 -F -i 4096 ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext4 -d ${WORKDIR}/rootfs
    dd if=/dev/zero of=${EMMC_IMAGE} bs=${BLOCK_SIZE} count=0 seek=$(expr ${EMMC_IMAGE_SIZE} \* ${BLOCK_SECTOR})
    parted -s ${EMMC_IMAGE} mklabel gpt
    parted -s ${EMMC_IMAGE} unit KiB mkpart boot fat16 ${IMAGE_ROOTFS_ALIGNMENT} $(expr ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_PARTITION_SIZE})
    parted -s ${EMMC_IMAGE} unit KiB mkpart kernel1 ${KERNEL_PARTITION_OFFSET} $(expr ${KERNEL_PARTITION_OFFSET} \+ ${KERNEL_PARTITION_SIZE})
    parted -s ${EMMC_IMAGE} unit KiB mkpart rootfs1 ext4 ${ROOTFS_PARTITION_OFFSET} $(expr ${ROOTFS_PARTITION_OFFSET} \+ ${ROOTFS_PARTITION_SIZE})
    parted -s ${EMMC_IMAGE} unit KiB mkpart kernel2 ${SECOND_KERNEL_PARTITION_OFFSET} $(expr ${SECOND_KERNEL_PARTITION_OFFSET} \+ ${KERNEL_PARTITION_SIZE})
    parted -s ${EMMC_IMAGE} unit KiB mkpart kernel3 ${THRID_KERNEL_PARTITION_OFFSET} $(expr ${THRID_KERNEL_PARTITION_OFFSET} \+ ${KERNEL_PARTITION_SIZE})
    parted -s ${EMMC_IMAGE} unit KiB mkpart kernel4 ${FOURTH_KERNEL_PARTITION_OFFSET} $(expr ${FOURTH_KERNEL_PARTITION_OFFSET} \+ ${KERNEL_PARTITION_SIZE})
    parted -s ${EMMC_IMAGE} unit KiB mkpart rootfs2 ext4 ${MULTI_ROOTFS_PARTITION_OFFSET} 100%
    dd if=/dev/zero of=${WORKDIR}/boot.img bs=${BLOCK_SIZE} count=$(expr ${BOOT_PARTITION_SIZE} \* ${BLOCK_SECTOR})
    mkfs.msdos -S 512 ${WORKDIR}/boot.img
    echo "boot emmcflash0.kernel1 'root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 rw rootwait ${MACHINE}_4.boxmode=1'" > ${WORKDIR}/STARTUP
    echo "boot emmcflash0.kernel1 'root=/dev/mmcblk0p7 rootsubdir=linuxrootfs1 rw rootwait ${MACHINE}_4.boxmode=1'" > ${WORKDIR}/STARTUP_LINUX_1_BOXMODE_1
    echo "boot emmcflash0.kernel2 'root=/dev/mmcblk0p7 rootsubdir=linuxrootfs2 rw rootwait ${MACHINE}_4.boxmode=1'" > ${WORKDIR}/STARTUP_LINUX_2_BOXMODE_1
    echo "boot emmcflash0.kernel3 'root=/dev/mmcblk0p7 rootsubdir=linuxrootfs3 rw rootwait ${MACHINE}_4.boxmode=1'" > ${WORKDIR}/STARTUP_LINUX_3_BOXMODE_1
    echo "boot emmcflash0.kernel4 'root=/dev/mmcblk0p7 rootsubdir=linuxrootfs4 rw rootwait ${MACHINE}_4.boxmode=1'" > ${WORKDIR}/STARTUP_LINUX_4_BOXMODE_1
    echo "boot emmcflash0.kernel1 'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 rw rootwait ${MACHINE}_4.boxmode=12'" > ${WORKDIR}/STARTUP_LINUX_1_BOXMODE_12
    echo "boot emmcflash0.kernel2 'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p7 rootsubdir=linuxrootfs2 rw rootwait ${MACHINE}_4.boxmode=12'" > ${WORKDIR}/STARTUP_LINUX_2_BOXMODE_12
    echo "boot emmcflash0.kernel3 'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p7 rootsubdir=linuxrootfs3 rw rootwait ${MACHINE}_4.boxmode=12'" > ${WORKDIR}/STARTUP_LINUX_3_BOXMODE_12
    echo "boot emmcflash0.kernel4 'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p7 rootsubdir=linuxrootfs4 rw rootwait ${MACHINE}_4.boxmode=12'" > ${WORKDIR}/STARTUP_LINUX_4_BOXMODE_12
    mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}/STARTUP ::
    mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}/STARTUP_LINUX_1_BOXMODE_1 ::
    mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}/STARTUP_LINUX_2_BOXMODE_1 ::
    mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}/STARTUP_LINUX_3_BOXMODE_1 ::
    mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}/STARTUP_LINUX_4_BOXMODE_1 ::
    mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}/STARTUP_LINUX_1_BOXMODE_12 ::
    mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}/STARTUP_LINUX_2_BOXMODE_12 ::
    mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}/STARTUP_LINUX_3_BOXMODE_12 ::
    mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}/STARTUP_LINUX_4_BOXMODE_12 ::
    dd conv=notrunc if=${WORKDIR}/boot.img of=${EMMC_IMAGE} bs=${BLOCK_SIZE} seek=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* ${BLOCK_SECTOR})
    dd conv=notrunc if=${DEPLOY_DIR_IMAGE}/zImage of=${EMMC_IMAGE} bs=${BLOCK_SIZE} seek=$(expr ${KERNEL_PARTITION_OFFSET} \* ${BLOCK_SECTOR})
    dd if=${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext4 of=${EMMC_IMAGE} bs=${BLOCK_SIZE} seek=$(expr ${ROOTFS_PARTITION_OFFSET} \* ${BLOCK_SECTOR})
}