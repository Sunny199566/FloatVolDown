ARCHS = arm64 arm64e
TARGET = iphone:clang:17.0:17.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

APP_NAME = VolDownFloat
VolDownFloat_FILES = main.m VolView.m
VolDownFloat_FRAMEWORKS = UIKit CoreGraphics
VolDownFloat_CFLAGS = -fobjc-arc
VolDownFloat_PRIVATE_FRAMEWORKS = GraphicsServices

include $(THEOS_MAKE_PATH)/app.mk