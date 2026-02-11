# DeviceAsWebcam
TARGET_BUILD_DEVICE_AS_WEBCAM := true

# OnePlus OOS Camera
#$(call inherit-product-if-exists, vendor/oplus/camera/opluscamera.mk)

# Dolby 
$(call inherit-product, hardware/oplus/dolby/dolby.mk)

# powerhal properties
PRODUCT_SYSTEM_PROPERTIES += \
    pm.sleep_mode=1

PRODUCT_VENDOR_PROPERTIES += \
    vendor.post_boot.parsed=1