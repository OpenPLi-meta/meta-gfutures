DESCRIPTION = "Linux kernel for ${MACHINE}"
SECTION = "kernel"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"
VER ?= "${@bb.utils.contains('TARGET_ARCH', 'aarch64', '64' , '', d)}"

KERNEL_RELEASE = "4.4.35"
SRCDATE = "20200219"
COMPATIBLE_MACHINE = "(hd31|hd41|hd60|hd61|hd66se)"

inherit kernel machine_kernel_pr
MACHINE_KERNEL_PR:append = ".9"

SRC_URI[arm.md5sum] = "f9e67e2d0ceab518510413f8f4315bc3"
SRC_URI[arm.sha256sum] = "45ae717b966a74326fd7297d81b3a17fd5b3962b7704170682a615ca7cdec644"

SRC_URI = "http://downloads.mutant-digital.net/linux-${PV}-${SRCDATE}-${ARCH}.tar.gz;name=${ARCH} \
	file://defconfig \
	file://0001-remote.patch \
	file://HauppaugeWinTV-dualHD.patch \
	file://dib7000-linux_4.4.179.patch \
	file://dvb-usb-linux_4.4.179.patch \
	file://wifi-linux_4.4.183.patch \
	file://initramfs-subdirboot.cpio.gz;unpack=0 \
	file://findkerneldevice.sh \
	file://0002-log2-give-up-on-gcc-constant-optimizations.patch \
	file://0003-dont-mark-register-as-const.patch \
	file://0004-linux-fix-buffer-size-warning-error.patch \
	file://Backport_minimal_compiler_attributes_h_to_support_GCC_9.patch \
	file://make-yyloc-declaration-extern.patch \
	file://fix-build-with-binutils-2.41.patch \
"

# By default, kernel.bbclass modifies package names to allow multiple kernels
# to be installed in parallel. We revert this change and rprovide the versioned
# package names instead, to allow only one kernel to be installed.
RPROVIDES:${KERNEL_PACKAGE_NAME}-base = "kernel-${KERNEL_VERSION}"
RPROVIDES:${KERNEL_PACKAGE_NAME}-image = "kernel-image-${KERNEL_VERSION}"

S = "${WORKDIR}/linux-${PV}"

export OS = "Linux"
KERNEL_OBJECT_SUFFIX = "ko"
KERNEL_IMAGEDEST = "tmp"
KERNEL_IMAGETYPE = "uImage"
KERNEL_OUTPUT = "arch/${ARCH}/boot/${KERNEL_IMAGETYPE}"

FILES:${KERNEL_PACKAGE_NAME}-image:hd31 = " "
FILES:${KERNEL_PACKAGE_NAME}-image:hd41 = " "
FILES:${KERNEL_PACKAGE_NAME}-image = "/${KERNEL_IMAGEDEST}/findkerneldevice.sh"

kernel_do_configure:prepend() {
    install -d ${B}/usr
    install -m 0644 ${WORKDIR}/initramfs-subdirboot.cpio.gz ${B}/
}

kernel_do_install:append:hd31() {
}

kernel_do_install:append:hd41() {
}

kernel_do_install:append() {
	install -d ${D}/${KERNEL_IMAGEDEST}
	install -m 0755 ${WORKDIR}/findkerneldevice.sh ${D}/${KERNEL_IMAGEDEST}
}

pkg_postinst:kernel-image:hd31() {
	if [ "x$D" == "x" ]; then
		if [ -f /${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE} ] ; then
			flash_eraseall /dev/${MTD_KERNEL}
			nandwrite -p /dev/${MTD_KERNEL} /${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE}
		fi
	fi
	true
}

pkg_postinst:kernel-image:hd41() {
	if [ "x$D" == "x" ]; then
		if [ -f /${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE} ] ; then
			flash_eraseall /dev/${MTD_KERNEL}
			nandwrite -p /dev/${MTD_KERNEL} /${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE}
		fi
	fi
	true
}

pkg_postinst:kernel-image() {
	if [ "x$D" == "x" ]; then
		if [ -f /${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE} ] ; then
			/${KERNEL_IMAGEDEST}/./findkerneldevice.sh
			dd if=/${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE} of=/dev/kernel
		fi
	fi
	true
}
