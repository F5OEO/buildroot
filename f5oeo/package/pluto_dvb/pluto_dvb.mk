################################################################################
#
# PLUTO_DVB
#
################################################################################

#DVB2IQ_VERSION = 2.2.5
PLUTO_DVB_SITE =  ~/prog/pluto_dvb
#DVB2IQ_SOURCE = /home/eric/plutosdr-fw/buildroot/dl/libdvbmod.tar.gz
#DVB2IQ_INSTALL_STAGING = YES
#DVB2IQ_AUTORECONF = YES
PLUTO_DVB_SITE_METHOD = local


define PLUTO_DVB_BUILD_CMDS
    $(MAKE) CC="$(TARGET_CXX)" LD="$(TARGET_LD)" -C $(@D)


endef
# $(MAKE) CC="$(TARGET_CC)"
#define LIBDVBMOD_INSTALL_TARGET_CMDS
#    $(INSTALL) -D -m 0755 $(@D)/hello $(TARGET_DIR)/usr/bin
#endef
define PLUTO_DVB_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/pluto_dvb $(TARGET_DIR)/usr/bin/pluto_dvb
endef
$(eval $(generic-package))

