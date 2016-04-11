#!/system/bin/sh

############################
# Custom Kernel Settings for Tyr Kernel by DerRomtester!!
# Credits to RenderBroken
echo "[Tyr-Kernel] Boot Script Started" | tee /dev/kmsg
stop mpdecision

# Scheduler and Read Ahead
echo bfq > /sys/block/mmcblk0/queue/scheduler;
echo 128 > /sys/block/mmcblk0/bdi/read_ahead_kb;
echo 0 /dev/cpuctl/cpu.notify_on_migrate;

# interactive
echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;
echo "interactive" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor;
echo "interactive" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor;
echo "interactive" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor;

# KSM
echo 1500 > /sys/kernel/mm/ksm/sleep_millisecs;
echo 256 > /sys/kernel/mm/ksm/pages_to_scan;
echo 1 > /sys/kernel/mm/ksm/deferred_timer;
echo 0 > /sys/kernel/mm/ksm/run;

# per_process_reclaim
echo 1 > /sys/module/process_reclaim/parameters/enable_process_reclaim;
echo 50 > /sys/module/process_reclaim/parameters/pressure_min;
echo 70 > /sys/module/process_reclaim/parameters/pressure_max;
echo 512 > /sys/module/process_reclaim/parameters/per_swap_size;
echo 30 > /sys/module/process_reclaim/parameters/swap_opt_eff;

echo "[Tyr-Kernel] Boot Script Completed!" | tee /dev/kmsg
