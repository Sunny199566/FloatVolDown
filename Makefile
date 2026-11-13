ARCHS = arm64 arm64e
TARGET = iphone:clang:16.0:16.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FloatVolDown

FloatVolDown_FILES = Tweak.x
FloatVolDown_CFLAGS = -fobjc-arc
FloatVolDown_FRAMEWORKS = UIKit AudioToolbox

BUNDLE_NAME = FloatVolDownPrefs
FloatVolDownPrefs_INSTALL_PATH = /Library/PreferenceBundles
FloatVolDownPrefs_FRAMEWORKS = UIKit Preferences
FloatVolDownPrefs_FILES = FloatVolDownPrefs.m
FloatVolDownPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk