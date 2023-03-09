#!/system/bin/sh
# This script is needed to automatically set device props.

load_op7t()
{
    resetprop "ro.product.model" "OnePlus 7T"
    resetprop "ro.product.name" "OnePlus7T"
    resetprop "ro.build.product" "OnePlus7T"
    resetprop "ro.product.device" "OnePlus7T"
    resetprop "ro.vendor.product.device" "OnePlus7T"
    resetprop "ro.display.series" "OnePlus 7T"
}

load_op7tpro()
{
    resetprop "ro.product.model" "OnePlus 7T Pro"
    resetprop "ro.product.name" "OnePlus7TPro"
    resetprop "ro.build.product" "OnePlus7TPro"
    resetprop "ro.product.device" "OnePlus7TPro"
    resetprop "ro.vendor.product.device" "OnePlus7TPro"
    resetprop "ro.display.series" "OnePlus 7T Pro"
}

project=$(getprop ro.boot.prjname)
echo $project

case $project in
    "18865")
        load_op7t
        ;;
    "19830")
        load_op7tpro
        ;;
    *)
esac

exit 0
