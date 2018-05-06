LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE :=curl
LOCAL_SRC_FILES :=curl/armeabi-v7a/libcurl.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_LDLIBS += -llog -lz
LOCAL_MODULE    := jni
#LOCAL_CPPFLAGS :=--std=C++11
LOCAL_SRC_FILES := WRITEREADAVOIDPASTE.c cJSON.c core.cpp jni.cpp json.cpp curl.cpp

LOCAL_STATIC_LIBRARIES := curl
include $(BUILD_SHARED_LIBRARY)