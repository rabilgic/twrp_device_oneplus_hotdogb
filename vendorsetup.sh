FDEVICE="hotdogb"
#set -o xtrace

fox_get_target_device() {
local chkdev=$(echo "$BASH_SOURCE" | grep -w $FDEVICE)
   if [ -n "$chkdev" ]; then 
      FOX_BUILD_DEVICE="$FDEVICE"
   else
      chkdev=$(set | grep BASH_ARGV | grep -w $FDEVICE)
      [ -n "$chkdev" ] && FOX_BUILD_DEVICE="$FDEVICE"
   fi
}

if [ -z "$1" -a -z "$FOX_BUILD_DEVICE" ]; then
   fox_get_target_device
fi

if [ "$1" = "$FDEVICE" -o "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then
    export TW_DEFAULT_LANGUAGE="en"
    export LC_ALL="C"
    export ALLOW_MISSING_DEPENDENCIES=true

    export OF_SCREEN_H=2340
    export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1

    export FOX_VERSION="R11.1_A13_FBEV2"
    export FOX_BUILD_TYPE=Alpha

    export OF_AB_DEVICE=1
    export OF_USE_MAGISKBOOT=1
    export OF_USE_MAGISKBOOT_FOR_ALL_PATCHES=1
    export FOX_USE_SPECIFIC_MAGISK_ZIP=~/Magisk/Magisk-v25.2.zip
    export OF_DONT_PATCH_ENCRYPTED_DEVICE=1
    export OF_DISABLE_MIUI_SPECIFIC_FEATURES=1
    export OF_SUPPORT_ALL_BLOCK_OTA_UPDATES=0

    export FOX_USE_NANO_EDITOR=1
    export FOX_USE_BASH_SHELL=1
    export FOX_ASH_IS_BASH=1
    export FOX_USE_TAR_BINARY=1
    export FOX_USE_SED_BINARY=1
    export FOX_USE_XZ_UTILS=1
    export OF_ENABLE_LPTOOLS=1
    
    export OF_PATCH_AVB20=1    
    export FOX_ADVANCED_SECURITY=1

    # Temp
    export OF_NO_SPLASH_CHANGE=1

    export OF_QUICK_BACKUP_LIST="/data;/super;"
    export TARGET_DEVICE_ALT="OnePlus7T,Oneplus 7T,OnePlus7TPro,Oneplus 7T Pro,hotdogb,hotdog"

    export FOX_REMOVE_AAPT=1
    export FOX_DISABLE_APP_MANAGER=1
    export FOX_DELETE_AROMAFM=1

    export OF_STATUS_INDENT_LEFT=64
    export OF_STATUS_INDENT_RIGHT=64

    export FOX_BUGGED_AOSP_ARB_WORKAROUND="1546300800"; # Tuesday, January 1, 2019 12:00:00 AM GMT+00:00

    export OF_MAINTAINER="rabilgic"

fi
#
