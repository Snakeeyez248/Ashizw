#!/system/bin/sh
# Ashizw - Action Script for KernelSU Button
# v1.2 - Toasts removed (unreliable outside WebUI context)

CONFIG_DIR="/data/adb/.config/ashizw"
LOG_FILE="$CONFIG_DIR/ashizw.log"
MODULE_ID="ashizw"

# Update KernelSU Dynamic Status
update_ksu_status() {
    status_msg="$1"
    if command -v ksud >/dev/null 2>&1; then
        ksud module config set override.description "$status_msg" 2>/dev/null
    fi
}

log() {
    echo "[*] $(date '+%Y-%m-%d %H:%M:%S'): [ACTION] $1" >> "$LOG_FILE"
}

# Print message to stdout (for KSU action screen) + log
show_message() {
    msg="$1"
    emoji="$2"
    # Print to stdout (visible in KSU action screen)
    echo "$emoji $msg"
    # Log to file
    log "$msg"
    # Keep on screen for 3 seconds so user can read
    sleep 3
}

start_shizuku() {
    echo "🔄 Ashizw: Starting Shizuku..."
    log "🚀 Starting Shizuku via Action..."
    update_ksu_status "🔄 Ashizw: Starting Shizuku..."
    
    LIB_PATH=$(find /data/app/ -type f -name "libshizuku.so" 2>/dev/null | head -n 1)

    if [ -z "$LIB_PATH" ]; then
        show_message "libshizuku.so not found! Check Shizuku setup." "❌"
        update_ksu_status "❌ Ashizw: libshizuku.so Not Found"
        return 1
    else
        echo "📍 Found: $LIB_PATH"
        chmod 755 "$LIB_PATH" 2>/dev/null
        "$LIB_PATH" &
        RET=$?
        
        if [ "$RET" -eq 0 ]; then
            show_message "Shizuku restored successfully!" "✅"
            update_ksu_status "✅ Ashizw: Shizuku Restored"
            sleep 2
            update_ksu_status "💓 Shizuku Running | Watchdog Active ✅"
        else
            show_message "Failed to start (Exit code: $RET)" "⚠️"
            update_ksu_status "⚠️ Ashizw: Start Failed (Code: $RET)"
        fi
    fi
}

# ============ MAIN ============

echo "=================================="
echo "   ✦ Ashizw Action ✦"
echo "=================================="

if pidof shizuku_server >/dev/null 2>&1; then
    echo "🛑 Stopping Shizuku..."
    log "🛑 Stopping Shizuku via Action..."
    update_ksu_status "🛑 Ashizw: Stopping Shizuku..."
    
    pkill -f shizuku_server 2>/dev/null
    pkill -f shizuku 2>/dev/null
    sleep 2
    
    if ! pidof shizuku_server >/dev/null 2>&1; then
        show_message "Shizuku stopped successfully!" "✅"
        update_ksu_status "⚠️ Shizuku Stopped | Tap Action to Start"
    else
        show_message "Failed to stop Shizuku" "⚠️"
        update_ksu_status "⚠️ Ashizw: Stop Failed"
    fi
else
    echo "⚠️ Shizuku is not running"
    echo "🔄 Attempting to start..."
    start_shizuku
fi

echo "=================================="
echo "✅ Action Complete"
echo "=================================="
sleep 2
exit 0