#!/system/bin/sh

MODDIR=${0%/*}
CONFIG_DIR="/data/adb/.config/ashizw"
CONFIG_FILE="$CONFIG_DIR/config.json"
LOG_FILE="$CONFIG_DIR/ashizw.log"
RELOAD_FLAG="$CONFIG_DIR/reload.flag"
MODULE_ID="ashizw"

log() {
    echo "[*] $(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Update KernelSU dynamic status
update_ksu_status() {
    status_msg="$1"
    if command -v ksud >/dev/null 2>&1; then
        ksud module config set override.description "$status_msg" 2>/dev/null || true
    fi
}

# Parse JSON config
get_config() {
    key=$1
    default=$2
    if [ -f "$CONFIG_FILE" ]; then
        val=$(grep "\"$key\"" "$CONFIG_FILE" 2>/dev/null | sed 's/[^0-9]//g')
        [ -z "$val" ] && echo "$default" || echo "$val"
    else
        echo "$default"
    fi
}

# Reload config from file (called when flag detected)
reload_config() {
    BOOT_DELAY=$(get_config "boot_delay" "45")
    CHECK_INTERVAL=$(get_config "check_interval" "1800")
    log "🔄 Config reloaded: Delay=${BOOT_DELAY}s, Interval=${CHECK_INTERVAL}s"
}

log "🚀 Ashizw Service Started"

# Initial config load
reload_config
log "⚙️ Boot Delay: ${BOOT_DELAY}s | Interval: ${CHECK_INTERVAL}s"
update_ksu_status "⏳ Ashizw Starting... (Delay: ${BOOT_DELAY}s)"

# Run watchdog in background
(
    # Boot delay (read once, makes sense)
    sleep "$BOOT_DELAY"
    update_ksu_status "💓 Shizuku Running | Watchdog Active ✅"
    
    while true; do
        # 🔥 Check for reload flag FIRST
        if [ -f "$RELOAD_FLAG" ]; then
            rm -f "$RELOAD_FLAG" 2>/dev/null
            reload_config
            update_ksu_status "💓 Shizuku Running | Watchdog Active ✅"
        fi
        
        # Check Shizuku status
        if pidof shizuku_server >/dev/null 2>&1; then
            log "💓 Heartbeat OK | Shizuku is running smoothly (Interval: ${CHECK_INTERVAL}s)"
            update_ksu_status "💓 Shizuku Running | Watchdog Active ✅"
        else
            log "⚠️ Shizuku missing. Deploying Ashizw... (Interval: ${CHECK_INTERVAL}s)"
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
                    update_ksu_status "✅ Ashizw: Shizuku Restored"
                    sleep 3
                    update_ksu_status "💓 Shizuku Running | Watchdog Active ✅"
                else
                    log "FAILED: Exit code $RET"
                    update_ksu_status "⚠️ Ashizw: Start Failed (Code: $RET)"
                fi
            fi
        fi
        
        # 🔥 CHUNKED SLEEP:  Check for reload every 10 seconds
        REMAINING=$CHECK_INTERVAL
        while [ "$REMAINING" -gt 0 ]; do
            # Check reload flag every 10 seconds
            if [ -f "$RELOAD_FLAG" ]; then
                rm -f "$RELOAD_FLAG" 2>/dev/null
                reload_config
                REMAINING=$CHECK_INTERVAL  # Reset with new interval
                log "⚡ Config changed mid-sleep! New interval: ${CHECK_INTERVAL}s"
                update_ksu_status "💓 Shizuku Running | Watchdog Active ✅"
            fi
            
            # Sleep in chunks (max 10 seconds per chunk)
            CHUNK=10
            [ "$REMAINING" -lt "$CHUNK" ] && CHUNK=$REMAINING
            sleep "$CHUNK"
            REMAINING=$((REMAINING - CHUNK))
        done
    done
) &

exit 0