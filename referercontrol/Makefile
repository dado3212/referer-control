ARCHS = armv7 arm64 arm64e

include theos/makefiles/common.mk

BUNDLE_NAME = RefererControl
RefererControl_FILES = RefererControl.mm
RefererControl_INSTALL_PATH = /Library/PreferenceBundles
RefererControl_FRAMEWORKS = UIKit
RefererControl_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/RefererControl.plist$(ECHO_END)
