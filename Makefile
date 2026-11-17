TARGET := iphone:clang:latest:15.0
ARCHS := arm64 arm64e
THEOS_PACKAGE_SCHEME ?= rootless
INSTALL_TARGET_PROCESSES := SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := BackGestureAndroid
BackGestureAndroid_FILES := Tweak.xm
BackGestureAndroid_CFLAGS := -fobjc-arc -Wno-deprecated-declarations
BackGestureAndroid_FRAMEWORKS := UIKit QuartzCore
BackGestureAndroid_PRIVATE_FRAMEWORKS :=

include $(THEOS_MAKE_PATH)/tweak.mk
