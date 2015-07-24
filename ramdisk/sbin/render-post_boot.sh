#!/system/bin/sh

BB=/sbin/bb/busybox

############################
# Custom Kernel Settings for Tyr!!
#
echo "[Tyr-Kernel] Boot Script Started" | tee /dev/kmsg

# cpufreq settings

echo 1574400 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq;
echo smartmax > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;
echo smartmax > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor;
echo smartmax > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor;
echo smartmax > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor;
echo 20 > /sys/module/cpu_boost/parameters/boost_ms 20;
echo 1728000 > /sys/module/cpu_boost/parameters/sync_threshold 1728000;
echo 1497600 > /sys/module/cpu_boost/parameters/input_boost_freq 1497600;
echo 40 > /sys/module/cpu_boost/parameters/input_boost_ms 40;
echo bfq > /sys/block/mmcblk0/queue/scheduler;
echo 1574400 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq;

echo "[Tyr-Kernel] Boot Script Completed!" | tee /dev/kmsg
