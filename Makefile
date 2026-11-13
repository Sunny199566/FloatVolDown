ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:15.0
THEOS_PACKAGE_SCHEME=rootless
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FloatVolDown

FloatVolDown_FILES = Tweak.x
FloatVolDown_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk