ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = RefererControl
RefererControl_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += referercontrol
include $(THEOS_MAKE_PATH)/aggregate.mk
