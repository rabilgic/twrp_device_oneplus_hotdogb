# Device Tree for OnePlus 7T aka Hotdogb for TWRP

## Disclaimer
These are personal test builds of mine. In no way do I hold responsibility if it/you messes up your device. Proceed at your own risk.

## Setup repo tool:
```
Setup repo tool from here https://source.android.com/setup/develop#installing-repo
```

## Compile:
```
## Sync twrp-11.0 manifest:
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11

<project name="rabilgic/twrp_device_oneplus_hotdogb" path="device/oneplus/hotdogb" remote="github" revision="Android-11" />

## Sync the sources with:
repo sync

## To build, execute these commands in order:
cd <source-dir>;. build/envsetup.sh; lunch twrp_hotdogb-eng; mka recoveryimage
```

## To test it:
```
- To temporarily boot it
fastboot boot out/target/product/hotdogb/recovery.img 

- Since 7T has a dedicated recovery parition, you can flash the recovery with
fastboot flash recovery recovery.img
```

### Working
- Decryption working (OOS11)
- ADB Sideload
- MTP is working
- ADB is working
- Vibration working
- Flashing zips (Stock Rom & Magisk)
- Format Data
- Backup
### Needs some testing
- Restore

### Kernel Source: precompiled stock one

### Credits
- lossyx for original trees
- nebrassy for original trees
- mauronofrio for original trees.
- CaptainThrowback for original trees.
- TWRP team and everyone involved for their amazing work.
