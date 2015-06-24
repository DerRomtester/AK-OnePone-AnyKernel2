#!/system/bin/sh

BB=/sbin/bb/busybox

############################
# Custom Kernel Settings for Tyr!!
#
echo "[Tyr-Kernel] Boot Script Started" | tee /dev/kmsg

# cpufreq settings

echo 1574400 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq;
echo conservative > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;
echo conservative > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor;
echo conservative > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor;
echo conservative > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor;
echo 90 > /sys/devices/system/cpu/cpufreq/conservative/up_threshold;
echo 10 > /sys/devices/system/cpu/cpufreq/conservative/freq_step;
echo 40 > /sys/devices/system/cpu/cpufreq/conservative/down_threshold;
echo 1497600 > /sys/devices/system/cpu/cpufreq/conservative/input_boost_freq;
echo 1574400 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq;

echo "[Tyr-Kernel] Boot Script Completed!" | tee /dev/kmsg
