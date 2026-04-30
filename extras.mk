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
    iorapd.perfetto.enable=false  

# Disable async MTE on a few processes
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.arm64.memtag.app.com.android.se=off \
    persist.arm64.memtag.app.com.google.android.bluetooth=off \
    persist.arm64.memtag.app.com.android.nfc=off \
    persist.arm64.memtag.process.system_server=off

# Enable Material Design 3 Expressive
PRODUCT_PRODUCT_PROPERTIES += is_expressive_design_enabled=true

# Enable dex2oat64 to do dexopt
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    dalvik.vm.dex2oat64.enabled=true

# Dexopt
ART_BUILD_HOST_DEBUG := false
ART_BUILD_TARGET_DEBUG := false

PRODUCT_SYSTEM_SERVER_DEBUG_INFO := false
WITH_DEXPREOPT_DEBUG_INFO := false

PRODUCT_PRODUCT_PROPERTIES += \
    pm.dexopt.downgrade_after_inactive_days=10 \
    dalvik.vm.enable_pr_dexopt=true \
    dalvik.vm.finalizer-timeout-ms=40000 \
    dalvik.vm.ps-min-first-save-ms=150000

PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.minidebuginfo=false \
    dalvik.vm.dex2oat-minidebuginfo=false

PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true
USE_DEX2OAT_DEBUG := false
OVERRIDE_DISABLE_DEXOPT_ALL := false
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile

PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := speed-profile
PRODUCT_SYSTEM_PROPERTIES += \
    pm.dexopt.post-boot=speed-profile \
    pm.dexopt.first-boot=verify \
    pm.dexopt.boot-after-ota=verify \
    pm.dexopt.boot-after-mainline-update=verify \
    pm.dexopt.install=speed-profile \
    pm.dexopt.install-fast=speed-profile \
    pm.dexopt.install-bulk=speed-profile \
    pm.dexopt.install-bulk-secondary=speed \
    pm.dexopt.install-bulk-downgraded=speed \
    pm.dexopt.install-bulk-secondary-downgraded=speed \
    pm.dexopt.bg-dexopt=speed \
    pm.dexopt.ab-ota=speed-profile \
    pm.dexopt.inactive=verify \
    pm.dexopt.cmdline=speed \
    pm.dexopt.first-use=speed-profile \
    pm.dexopt.secondary=speed-profile \
    pm.dexopt.shared=speed \
    dalvik.vm.dex2oat-filter=speed \
    dalvik.vm.image-dex2oat-filter=speed \
    dalvik.vm.dex2oat-cpu-set=0,1,2,3,4,5,6 \
    dalvik.vm.dex2oat-threads=6

PRODUCT_DEX_PREOPT_DEFAULT_FLAGS += \
    --compiler-filter=speed-profile

$(call add-product-dex-preopt-module-config,services,--compiler-filter=speed)
$(call add-product-dex-preopt-module-config,wifi-service,--compiler-filter=speed)
$(call add-product-dex-preopt-module-config,framework,--compiler-filter=speed-profile)

