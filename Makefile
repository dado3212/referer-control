ARCHS = armv7 arm64 arm64e

THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
FINALPACKAGE = 0

include theos/makefiles/common.mk

TWEAK_NAME = RefererControl
RefererControl_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += referercontrol
include $(THEOS_MAKE_PATH)/aggregate.mk
