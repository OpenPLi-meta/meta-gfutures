KV = "4.4.35"
SRCDATE = "20220505"

PROVIDES += "virtual/blindscan-dvbs"
RPROVIDES:${PN} += "virtual/blindscan-dvbs"

require hd-dvb-modules-hisil.inc

SRC_URI[md5sum] = "baf26d2a6a901e70358c4e9fba377231"
SRC_URI[sha256sum] = "dde41f50d581f495097a90ed042ea9f90f882f5bcb93599991822bf845a8d397"

COMPATIBLE_MACHINE = "hd61"
