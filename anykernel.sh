# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# EDIFY properties
kernel.string=PrivateKernel
do.devicecheck=1
do.initd=1
do.modules=1
do.cleanup=0
device.name1=A0001
device.name2=bacon
device.name3=One A0001
device.name4=One
device.name5=OnePlus

# shell variables
block=/dev/block/platform/msm_sdcc.1/by-name/boot;
initd=/system/etc/init.d;
bindir=/system/bin;
## end setup


## AnyKernel methods (DO NOT CHANGE)
# set up extracted files and directories
ramdisk=/tmp/anykernel/ramdisk;
bin=/tmp/anykernel/tools;
split_img=/tmp/anykernel/split_img;
patch=/tmp/anykernel/patch;

chmod -R 755 $bin;
mkdir -p $ramdisk $split_img;

OUTFD=/proc/self/fd/$1;

# ui_print <text>
ui_print() { echo -e "ui_print $1\nui_print" > $OUTFD; }

# contains <string> <substring>
contains() { test "${1#*$2}" != "$1" && return 0 || return 1; }

# dump boot and extract ramdisk
dump_boot() {
  dd if=$block of=/tmp/anykernel/boot.img;
  $bin/unpackbootimg -i /tmp/anykernel/boot.img -o $split_img;
  if [ $? != 0 ]; then
    ui_print " "; ui_print "Dumping/splitting image failed. Aborting..."; exit 1;
  fi;
  mv -f $ramdisk /tmp/anykernel/rdtmp;
  mkdir -p $ramdisk;
  cd $ramdisk;
  gunzip -c $split_img/boot.img-ramdisk.gz | cpio -i;
  if [ $? != 0 -o -z "$(ls $ramdisk)" ]; then
    ui_print " "; ui_print "Unpacking ramdisk failed. Aborting..."; exit 1;
  fi;
  cp -af /tmp/anykernel/rdtmp/* $ramdisk;
}

# repack ramdisk then build and write image
write_boot() {
  cd $split_img;
  cmdline=`cat *-cmdline`;
  board=`cat *-board`;
  base=`cat *-base`;
  pagesize=`cat *-pagesize`;
  kerneloff=`cat *-kerneloff`;
  ramdiskoff=`cat *-ramdiskoff`;
  tagsoff=`cat *-tagsoff`;
  if [ -f *-second ]; then
    second=`ls *-second`;
    second="--second $split_img/$second";
    secondoff=`cat *-secondoff`;
    secondoff="--second_offset $secondoff";
  fi;
  if [ -f /tmp/anykernel/zImage ]; then
    kernel=/tmp/anykernel/zImage;
  else
    kernel=`ls *-zImage`;
    kernel=$split_img/$kernel;
  fi;
  if [ -f /tmp/anykernel/dtb ]; then
    dtb="--dt /tmp/anykernel/dtb";
  elif [ -f *-dtb ]; then
    dtb=`ls *-dtb`;
    dtb="--dt $split_img/$dtb";
  fi;
  cd $ramdisk;
  find . | cpio -H newc -o | gzip > /tmp/anykernel/ramdisk-new.cpio.gz;
  if [ $? != 0 ]; then
    ui_print " "; ui_print "Repacking ramdisk failed. Aborting..."; exit 1;
  fi;
  $bin/mkbootimg --kernel $kernel --ramdisk /tmp/anykernel/ramdisk-new.cpio.gz $second --cmdline "$cmdline" --board "$board" --base $base --pagesize $pagesize --kernel_offset $kerneloff --ramdisk_offset $ramdiskoff $secondoff --tags_offset $tagsoff $dtb --output /tmp/anykernel/boot-new.img;
  if [ $? != 0 ]; then
    ui_print " "; ui_print "Repacking image failed. Aborting..."; exit 1;
  elif [ `wc -c < /tmp/anykernel/boot-new.img` -gt `wc -c < /tmp/anykernel/boot.img` ]; then
    ui_print " "; ui_print "New image larger than boot partition. Aborting..."; exit 1;
  fi;
  if [ -f "/data/custom_boot_image_patch.sh" ]; then
    ash /data/custom_boot_image_patch.sh /tmp/anykernel/boot-new.img;
    if [ $? != 0 ]; then
      ui_print " "; ui_print "User script execution failed. Aborting..."; exit 1;
    fi;
  fi;
  dd if=/tmp/anykernel/boot-new.img of=$block;
}

# backup_file <file>
backup_file() { cp $1 $1~; }

# replace_string <file> <if search string> <original string> <replacement string>
replace_string() {
  if [ -z "$(grep "$2" $1)" ]; then
      sed -i "s;${3};${4};" $1;
  fi;
}

# replace_section <file> <begin search string> <end search string> <replacement string>
replace_section() {
  line=`grep -n "$2" $1 | cut -d: -f1`;
  sed -i "/${2}/,/${3}/d" $1;
  sed -i "${line}s;^;${4}\n;" $1;
}

# remove_section <file> <begin search string> <end search string>
remove_section() {
  sed -i "/${2}/,/${3}/d" $1;
}

# insert_line <file> <if search string> <before|after> <line match string> <inserted line>
insert_line() {
  if [ -z "$(grep "$2" $1)" ]; then
    case $3 in
      before) offset=0;;
      after) offset=1;;
    esac;
    line=$((`grep -n "$4" $1 | cut -d: -f1` + offset));
    sed -i "${line}s;^;${5}\n;" $1;
  fi;
}

# replace_line <file> <line replace string> <replacement line>
replace_line() {
  if [ ! -z "$(grep "$2" $1)" ]; then
    line=`grep -n "$2" $1 | cut -d: -f1`;
    sed -i "${line}s;.*;${3};" $1;
  fi;
}

# remove_line <file> <line match string>
remove_line() {
  if [ ! -z "$(grep "$2" $1)" ]; then
    line=`grep -n "$2" $1 | cut -d: -f1`;
    sed -i "${line}d" $1;
  fi;
}

# prepend_file <file> <if search string> <patch file>
prepend_file() {
  if [ -z "$(grep "$2" $1)" ]; then
    echo "$(cat $patch/$3 $1)" > $1;
  fi;
}

# insert_file <file> <if search string> <before|after> <line match string> <patch file>
insert_file() {
  if [ -z "$(grep "$2" $1)" ]; then
    case $3 in
      before) offset=0;;
      after) offset=1;;
    esac;
    line=$((`grep -n "$4" $1 | cut -d: -f1` + offset));
    sed -i "${line}s;^;\n;" $1;
    sed -i "$((line - 1))r $patch/$5" $1;
  fi;
}

# append_file <file> <if search string> <patch file>
append_file() {
  if [ -z "$(grep "$2" $1)" ]; then
    echo -ne "\n" >> $1;
    cat $patch/$3 >> $1;
    echo -ne "\n" >> $1;
  fi;
}

# replace_file <file> <permissions> <patch file>
replace_file() {
  cp -pf $patch/$3 $1;
  chmod $2 $1;
}

# patch_fstab <fstab file> <mount match name> <fs match type> <block|mount|fstype|options|flags> <original string> <replacement string>
patch_fstab() {
  entry=$(grep "$2" $1 | grep "$3");
  if [ -z "$(echo "$entry" | grep "$6")" ]; then
    case $4 in
      block) part=$(echo "$entry" | awk '{ print $1 }');;
      mount) part=$(echo "$entry" | awk '{ print $2 }');;
      fstype) part=$(echo "$entry" | awk '{ print $3 }');;
      options) part=$(echo "$entry" | awk '{ print $4 }');;
      flags) part=$(echo "$entry" | awk '{ print $5 }');;
    esac;
    newentry=$(echo "$entry" | sed "s;${part};${6};");
    sed -i "s;${entry};${newentry};" $1;
  fi;
}

## end methods


## AnyKernel permissions
# set permissions for included files
#chmod -R 755 $ramdisk
#chmod 644 $ramdisk/sbin/media_profiles.xml

## AnyKernel install
dump_boot;

# insert initd scripts
cp -fp $patch/init.d/* $initd
chmod -R 766 $initd

# 3.10 ramdisk fixes

## AnyKernel permissions
chmod -R 755 $ramdisk

## AnyKernel install
dump_boot;

## 3.10 ramdisk fixes

# fstab

if [ -f fstab.bacon ]; then
  fstab="fstab.bacon";
  backup_file $fstab;
elif [ -f fstab.qcom ]; then
  fstab="fstab.qcom";
  backup_file $fstab;
fi;

if [ -n $fstab ]; then
  replace_string $fstab "/dev/block/platform/msm_sdcc.1/by-name/userdata     /data           f2fs    nosuid" "/dev/block/platform/msm_sdcc.1/by-name/userdata     /data           f2fs    noatime,nosuid" "/dev/block/platform/msm_sdcc.1/by-name/userdata     /data           f2fs    nosuid";
  replace_string $fstab "/dev/block/platform/msm_sdcc.1/by-name/cache        /cache          f2fs    nosuid" "/dev/block/platform/msm_sdcc.1/by-name/cache        /cache          f2fs    noatime,nosuid" "/dev/block/platform/msm_sdcc.1/by-name/cache        /cache          f2fs    nosuid";
fi;

# init.recovery.bacon.rc

if [ -f init.recovery.bacon.rc ]; then
  qcomrecovery="init.recovery.bacon.rc";
  backup_file $qcomrecovery;
fi;

if [ -n $qcomrecovery ]; then
  replace_string $qcomrecovery "cpubw.47" "cpubw.40" "cpubw.47";
fi;

# init.qcom.power.rc 

if [ -f init.qcom.power.rc ]; then
  qcompower="init.qcom.power.rc";
  backup_file $qcompower;
fi;

if [ -n $qcompower ]; then
  replace_string $qcompower "cpubw.47" "cpubw.40" "cpubw.47";
fi;

# init.bacon.rc

if [ -f init.bacon.rc ]; then
  qcomdevice="init.bacon.rc";
  backup_file $qcomdevice;
elif [ -f init.oppo.common.rc ]; then
  qcomdevice="init.oppo.common.rc";
  backup_file $qcomdevice;
fi;

if [ -n $qcomdevice ]; then
  replace_string $qcomdevice "# loc_launcher qcom_oncrps not needed" "    group gps qcom_oncrpc inet" "    # loc_launcher qcom_oncrps not needed\n    group gps inet";
  replace_string_multiline $qcomdevice "# fix netmgrd service" "service netmgrd \/system\/bin\/netmgrd\n    class main\n    user root\n    group radio" "service netmgrd \/system\/bin\/netmgrd\n    class main\n    user root\n    # fix netmgrd service\n    group radio system";
  replace_string_multiline $qcomdevice "# fix qmuxd service" "service qmuxd \/system\/bin\/qmuxd\n    class main\n    user radio" "service qmuxd \/system\/bin\/qmuxd\n    class main\n    # fix qmuxd service\n    user root";
fi;

## 3.10 ramdisk fixes

write_boot;

## end install
