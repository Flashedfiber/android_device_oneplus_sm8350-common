# DeviceAsWebcam
TARGET_BUILD_DEVICE_AS_WEBCAM := true

# Torch
$(call soong_config_set,libcameraservice,ext_lib,//$(LOCAL_PATH):libcameraservice_extension.oneplus_sm8350)

# OnePlus OOS Camera
$(call inherit-product-if-exists, vendor/oplus/camera/opluscamera.mk)

# Dolby 
$(call inherit-product, hardware/oplus/dolby/dolby.mk)

PRODUCT_VENDOR_PROPERTIES += \
    ro.egl.blobcache.multifile=true \
    ro.egl.blobcache.multifile_limit=33554432 \
    debug.sf.disable_backpressure=0 \
    debug.sf.enable_gl_backpressure=1 \
    debug.hwui.renderer=skiagl \
    debug.renderengine.backend=skiaglthreaded 

PRODUCT_PRODUCT_PROPERTIES += \
    renderthread.skia.reduceopstasksplitting=true

PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.perf.scroll_opt=true \
    persist.sys.perf.scroll_opt.heavy_app=1 \
    ro.iorapd.enable=false \
    persist.device_config.runtime_native_boot.iorap_readahead_enable=false