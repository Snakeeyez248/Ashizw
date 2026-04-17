#!/system/bin/sh
# Ashizw - Action Script for KernelSU Button
# v1.3 - Volume key confirmation + Shizuku app launcher

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

stop_shizuku() {
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
}

open_shizuku_app() {
    echo "📱 Opening Shizuku app..."
    log "📱 Opening Shizuku app..."
    
    # Direct command that works without 'Open with' menu
    su -c "am start -n moe.shizuku.privileged.api/moe.shizuku.manager.MainActivity" >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        show_message "Shizuku app opened" "✅"
        return 0
    else
        show_message "Failed to open Shizuku app" "⚠️"
        return 1
    fi
}

# ============ MAIN ============

echo ""
echo "================================="
echo "   Ashizw Quick Action"
echo "================================="
echo ""

# Determine current state
if pidof shizuku_server >/dev/null 2>&1; then
    CURRENT_STATE="running"
    ACTION_NAME="Stop"
    STATE_ICON="💓"
else
    CURRENT_STATE="stopped"
    ACTION_NAME="Start"
    STATE_ICON="⚠️"
fi

echo "  Status: $STATE_ICON $CURRENT_STATE"
echo ""
echo "  [Vol ↑]  $ACTION_NAME Shizuku"
echo "  [Vol ↓]  Open Shizuku App"
echo ""
echo "  Waiting (10s)..."
echo "---------------------------------"
log "Action menu displayed. State: $CURRENT_STATE"

# Wait for volume key (max 10 seconds)
timeout=0
while [ $timeout -lt 100 ]; do
    event=$(getevent -qlc 1 2>/dev/null)
    
    if echo "$event" | grep -q "KEY_VOLUMEUP"; then
        echo "→ VOLUME UP: $ACTION_NAME Shizuku"
        log "Volume Up pressed: $ACTION_NAME action"
        
        if [ "$CURRENT_STATE" = "running" ]; then
            stop_shizuku
        else
            start_shizuku
        fi
        break
        
    elif echo "$event" | grep -q "KEY_VOLUMEDOWN"; then
        echo "→ VOLUME DOWN: Open Shizuku App"
        log "Volume Down pressed: Open app"
        open_shizuku_app
        break
    fi
    
    timeout=$((timeout + 1))
    sleep 0.1
done

if [ $timeout -ge 100 ]; then
    echo "⚠️  Timeout: No input."
fi

exit 0