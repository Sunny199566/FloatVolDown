ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:17.0
INSTALL_TARGET_PROCESSES = SpringBoard
NO_CODESIGN = 1
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FloatVolDown

FloatVolDown_FILES = Tweak.x
FloatVolDown_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk