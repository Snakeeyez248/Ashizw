#!/system/bin/sh

MODDIR=${0%/*}
CONFIG_DIR="/data/adb/.config/ashizw"
CONFIG_FILE="$CONFIG_DIR/config.json"
LOG_FILE="$CONFIG_DIR/ashizw.log"
MODULE_ID="ashizw"

log() {
    echo "[*] $(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Update KernelSU dynamic status
update_ksu_status() {
    status_msg="$1"
    if command -v ksud >/dev/null 2>&1; then
        ksud module config set override.description "$status_msg"
    fi
}

# Parse JSON config
get_config() {
    key=$1
    grep "\"$key\"" "$CONFIG_FILE" | sed 's/[^0-9]//g'
}

BOOT_DELAY=$(get_config "boot_delay")
CHECK_INTERVAL=$(get_config "check_interval")

# Fallback if parsing fails
[ -z "$BOOT_DELAY" ] && BOOT_DELAY=45
[ -z "$CHECK_INTERVAL" ] && CHECK_INTERVAL=1800

log "🚀 Ashizw Service Started"
log "⚙️ Boot Delay: ${BOOT_DELAY}s | Interval: ${CHECK_INTERVAL}s"

# Set initial status
update_ksu_status "⏳ Ashizw Starting... (Delay: ${BOOT_DELAY}s)"

# Run watchdog in background
(
    sleep "$BOOT_DELAY"
    
    while true; do
        # 🔥 FIX: Re-read interval on every loop iteration
        CHECK_INTERVAL=$(get_config "check_interval")
        [ -z "$CHECK_INTERVAL" ] && CHECK_INTERVAL=1800
        
        if pidof shizuku_server >/dev/null 2>&1; then
            log "💓 Heartbeat OK | Shizuku is running smoothly"
            update_ksu_status "💓 Shizuku Running | Watchdog Active ✅"
        else
            log "⚠️ Shizuku missing. Deploying Ashizw..."
            update_ksu_status "🔄 Ashizw: Restarting Shizuku..."

            LIB_PATH=$(find /data/app/ -type f -name "libshizuku.so" 2>/dev/null | head -n 1)

            if [ -z "$LIB_PATH" ]; then
                log "ERROR: libshizuku.so not found!"
                update_ksu_status "❌ Ashizw: libshizuku.so Not Found"
            else
                log "Located: $LIB_PATH"
                chmod 755 "$LIB_PATH" 2>/dev/null

                "$LIB_PATH"
                RET=$?

                if [ "$RET" -eq 0 ]; then
                    log "SUCCESS: Shizuku restored by Ashizw."
                    update_ksu_status "✅ Ashizw: Shizuku Restored Successfully"
                    sleep 5
                    update_ksu_status "💓 Shizuku Running | Watchdog Active ✅"
                else
                    log "FAILED: Exit code $RET"
                    update_ksu_status "⚠️ Ashizw: Start Failed (Code: $RET)"
                fi
            fi
        fi
        sleep "$CHECK_INTERVAL"
    done
) &

exit 0