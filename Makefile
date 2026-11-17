TARGET := iphone:clang:latest:15.0
ARCHS := arm64e
THEOS_PACKAGE_SCHEME := roothide
DEB_ARCH := iphoneos-arm64e
INSTALL_TARGET_PROCESSES :=

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := BackGestureAndroid
BackGestureAndroid_FILES := Tweak.xm
BackGestureAndroid_CFLAGS := -fobjc-arc -Wno-deprecated-declarations
BackGestureAndroid_FRAMEWORKS := UIKit QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
