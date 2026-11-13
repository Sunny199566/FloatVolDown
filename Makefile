ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:17.0
INSTALL_TARGET_PROCESSES = SpringBoard
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FloatVolDown

FloatVolDown_FILES = Tweak.x
# 关闭把警告当成错误，避免SDK废弃提示直接炸编译
FloatVolDown_CFLAGS = -fobjc-arc -Wno-error=deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk