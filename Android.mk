LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),hotdogb)
include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
