ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:17.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FloatVolDown

FloatVolDown_FILES = Tweak.x
FloatVolDown_CFLAGS = -fobjc-arc

# rootless 必须加这个！适配你的 NathanLR
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS_MAKE_PATH)/tweak.mk