DESCRIPTION = "Hardware drivers for ${MACHINE}"
SECTION = "base"
PRIORITY = "required"
LICENSE = "CLOSED"

PV = "${KV}+${SRCDATE}"

SRC_URI = "http://downloads.openpli.org/archive/gfutures/${MACHINE}-drivers-${KV}-${SRCDATE}.zip"

S = "${WORKDIR}"

INHIBIT_PACKAGE_STRIP = "1"

inherit module

FILES_${PN} += "${sysconfdir}/modules-load.d/${MACHINE}.conf"

do_compile() {
}

do_install() {
	install -d ${D}/lib/modules/${KV}/extra
	install -d ${D}/${sysconfdir}/modules-load.d
	install -m 0755 ${S}/*.ko ${D}${base_libdir}/modules/${KV}/extra
	for i in ${MACHINE}_1 ${MACHINE}_2 ${MACHINE}_3 ${MACHINE}_4; do
		echo $i >> ${D}/${sysconfdir}/modules-load.d/${MACHINE}.conf
	done
}
