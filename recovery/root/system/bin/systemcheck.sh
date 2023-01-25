#!/sbin/sh

# The below variables shouldn't need to be changed
# unless you want to call the script something else
SCRIPTNAME="systemcheck"
LOGFILE=/tmp/recovery.log


# Set default log level
DEFAULT_LOGLEVEL=1
# 0 Errors only
# 1 Errors and Information
# 2 Errors, Information, and Debugging
CUSTOM_LOGLEVEL=$(getprop $SCRIPTNAME.loglevel)
if [ -n "$CUSTOM_LOGLEVEL" ]; then
	__VERBOSE="$CUSTOM_LOGLEVEL"
else
	__VERBOSE="$DEFAULT_LOGLEVEL"
fi

# Exit codes:
# 0 Success
# 1 Unknown encryption type
# 2 Temp Mount Failure

# Function for logging to the recovery log
log_print()
{
	# 0 = Error; 1 = Information; 2 = Debugging
	case $1 in
		0|error)
			LOG_LEVEL="E"
			;;
		1|info)
			LOG_LEVEL="I"
			;;
		2|debug)
			LOG_LEVEL="DEBUG"
			;;
		*)
			LOG_LEVEL="UNKNOWN"
			;;
	esac
	if [ $__VERBOSE -ge "$1" ]; then
		echo "$LOG_LEVEL:$SCRIPTNAME::$2" >> "$LOGFILE"
	fi
}


finish()
{
	setprop fstab.ready 1
	log_print 1 "fstab.ready=$(getprop fstab.ready)"
	log_print 1 "Script complete."
	exit 0
}

finish_error()
{
	is_system_mounted=$(getprop $SCRIPTNAME.system_mounted)
	if [ "$is_system_mounted" = 1 ]; then
		umount "$TEMPSYS"
		$setprop_bin $SCRIPTNAME.system_mounted 0
		rmdir "$TEMPSYS"
	fi
	is_vendor_mounted=$(getprop $SCRIPTNAME.vendor_mounted)
	if [ "$is_vendor_mounted" = 1 ]; then
		umount "$TEMPVEN"
		$setprop_bin $SCRIPTNAME.vendor_mounted 0
		rmdir "$TEMPVEN"
	fi
	log_print 0 "Script run incomplete. No modifications made."
	exit 2
}

check_resetprop()
{
	if [ -e /system/bin/resetprop ] || [ -e /sbin/resetprop ]; then
		log_print 2 "Resetprop binary found!"
		setprop_bin=resetprop
	else
		log_print 2 "Resetprop binary not found. Falling back to setprop."
		setprop_bin=setprop
	fi
}

# remove_line <file> <line match string> <scope>
remove_line() {
  local lines line;
  if grep -q "$2" $1; then
    lines=$(grep -E -n "$2" $1 | cut -d: -f1 | sort -nr);
    [ "$3" = "global" ] || lines=$(echo "$lines" | tail -n1);
    for line in $lines; do
      sed -i "${line}d" $1;
    done;
  fi;
}

# remove_section <file> <begin search string> <end search string>
remove_section() {
  local begin endstr last end;
  begin=$(grep -n "$2" $1 | head -n1 | cut -d: -f1);
  if [ "$begin" ]; then
    if [ "$3" = " " -o ! "$3" ]; then
      endstr='^[[:space:]]*$';
      last=$(wc -l $1 | cut -d\  -f1);
    else
      endstr="$3";
    fi;
    for end in $(grep -n "$endstr" $1 | cut -d: -f1) $last; do
      if [ "$end" ] && [ "$begin" -lt "$end" ]; then
        sed -i "${begin},${end}d" $1;
        break;
      fi;
    done;
  fi;
}

temp_mount()
{
	is_mounted=$(ls -A "$1" 2>/dev/null)
	if [ -n "$is_mounted" ]; then
		log_print 1 "$2 already mounted."
	else
		mkdir -p "$1"
		if [ -d "$1" ]; then
			log_print 2 "Temporary $2 folder created at $1."
		else
			log_print 0 "Unable to create temporary $2 folder."
			finish_error
		fi
		mount -t ext4 -o ro "$3" "$1"
		is_mounted=$(ls -A "$1" 2>/dev/null)
		if [ -n "$is_mounted" ]; then
			log_print 2 "$2 mounted at $1."
			$setprop_bin $SCRIPTNAME."$2"_mounted 1
			log_print 2 "$SCRIPTNAME.$2_mounted=$(getprop "$SCRIPTNAME"."$2"_mounted)"
		else
			log_print 0 "Unable to mount $2 to temporary folder."
			finish_error
		fi
	fi
}

unmount_system()
{
	is_system_mounted=$(getprop $SCRIPTNAME.system_mounted)
	if [ "$is_system_mounted" = 1 ]; then
		umount "$TEMPSYS"
		$setprop_bin $SCRIPTNAME.system_mounted 0
		rmdir "$TEMPSYS"
	fi
}


log_print 2 "Running $SCRIPTNAME script for TWRP..."

ab_device=$(getprop ro.build.ab_update)
sdkver=$(getprop ro.build.version.sdk)
if [ -n "$ab_device" ]; then
	log_print 2 "A/B device detected! Finding current boot slot..."
	suffix=$(getprop ro.boot.slot_suffix)
	if [ -z "$suffix" ]; then
		suf=$(getprop ro.boot.slot)
		if [ -n "$suf" ]; then
			suffix="_$suf"
		fi
	fi
	log_print 2 "Current boot slot: $suffix"
fi
if [ "$sdkver" -ge 26 ]; then
	if [ -z "$setprop_bin" ]; then
		check_resetprop
	fi
fi

BUILDPROP="system/build.prop"
vendor_manifest="/vendor/etc/vintf/manifest.xml"
TEMPSYS="/s"
syspath="/dev/block/bootdevice/by-name/system$suffix"

temp_mount "$TEMPSYS" "system" "$syspath"
if [ -f "$TEMPSYS/$BUILDPROP" ]; then
	log_print 2 "Build.prop exists! Reading system properties from build.prop..."
	flavor=$(grep -i 'ro.build.flavor=' "$TEMPSYS/$BUILDPROP"  | cut -f2 -d'=' -s)
	unmount_system
	log_print 2 "Current system flavor: $flavor"
	decrypt_rc="/init.recovery.qcom_decrypt.rc"
	decrypt_fbe_rc="init.recovery.qcom_decrypt.fbe.rc"
	recovery_fstab="/etc/recovery.fstab"
	if [[ "$flavor" == bliss* ]] || [[ "$flavor" == voltage* ]]; then
		sed -i 's/,inlinecrypt//' "$recovery_fstab"
		sed -i 's/,wrappedkey//' "$recovery_fstab"
		remove_section "$decrypt_rc" "android.hardware.keymaster@4.0-service-qti"
		remove_line "$decrypt_rc" "keymaster-4-0-qti" "global"
		remove_line "$decrypt_fbe_rc" "keymaster-4-0-qti" "global"
		sed -i "s/4.0/4.1/" "$vendor_manifest"
	else
		remove_section "$decrypt_rc" "android.hardware.keymaster@4.1-service-qti"
		remove_line "$decrypt_rc" "keymaster-4-1-qti" "global"
		remove_line "$decrypt_fbe_rc" "keymaster-4-1-qti" "global"
	fi
fi

finish

