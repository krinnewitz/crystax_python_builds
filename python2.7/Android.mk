LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := python_shared
LOCAL_SRC_FILES := libs/$(TARGET_ARCH_ABI)/libpython2.7.so
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include/python
include $(PREBUILT_SHARED_LIBRARY)
