#!/system/bin/sh

############################
# Custom Kernel Settings for Tyr Kernel by DerRomtester!!
# Credits to RenderBroken
echo "[Tyr-Kernel] Boot Script Started" | tee /dev/kmsg
stop mpdecision

############################
# Scheduler and Read Ahead
#
echo bfq > /sys/block/mmcblk0/queue/scheduler
echo 128 > /sys/block/mmcblk0/bdi/read_ahead_kb

############################
# Governor Tunings
#
echo "1497600 1190400" > /sys/kernel/cpu_input_boost/ib_freqs
echo interactive > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo interactive > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo interactive > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo interactive > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo "[Tyr-Kernel] Boot Script Completed!" | tee /dev/kmsg
