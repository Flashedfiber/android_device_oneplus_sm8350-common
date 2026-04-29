# DeviceAsWebcam
TARGET_BUILD_DEVICE_AS_WEBCAM := true

# Torch
$(call soong_config_set,libcameraservice,ext_lib,//$(LOCAL_PATH):libcameraservice_extension.oneplus_sm8350)

# OnePlus OOS Camera
$(call inherit-product-if-exists, vendor/oplus/camera/opluscamera.mk)

# Dolby 
$(call inherit-product, vendor/sony/dolby/sonydolby.mk)

# System properties
PRODUCT_SYSTEM_PROPERTIES += \
    ro.iorapd.enable=false \
    iorapd.perfetto.enable=false \
    libc.debug.malloc.program=android.hardware.camera.provider@2.4-service_64 \
    libc.debug.malloc.options=rear_guard=4096