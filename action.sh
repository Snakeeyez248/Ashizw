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
    
    # Try multiple methods to open Shizuku app
    am start -n moe.shizuku.privileged.api/moe.shizuku.main.ui.MainActivity >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        show_message "Shizuku app opened" "✅"
        return 0
    fi
    
    # Fallback: try using package name only
    am start -p moe.shizuku.privileged.api >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        show_message "Shizuku app opened" "✅"
        return 0
    fi
    
    # Last resort: try monkey command
    monkey -p moe.shizuku.privileged.api -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        show_message "Shizuku app opened" "✅"
        return 0
    fi
    
    show_message "Failed to open Shizuku app" "⚠️"
    return 1
}

# ============ MAIN ============

echo ""
echo "╔═══════════════════════════════════╗"
echo "║     ✦ Ashizw Action Panel ✦       ║"
echo "╚═══════════════════════════════════╝"
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

echo "┌───────────────────────────────────────┐"
echo "│                                       │"
echo "│   Shizuku Status: $STATE_ICON $CURRENT_STATE                  │"
echo "│                                       │"
echo "│   ┌─────────────────────────────────┐ │"
echo "│   │  [↑] VOLUME UP                  │ │"
echo "│   │      → $ACTION_NAME Shizuku                │ │"
echo "│   │                                 │ │"
echo "│   │  [↓] VOLUME DOWN                │ │"
echo "│   │      → Open Shizuku App         │ │"
echo "│   └─────────────────────────────────┘ │"
echo "│                                       │"
echo "│   ⏱ Waiting for input (10s timeout)  │"
echo "└───────────────────────────────────────┘"
echo ""
echo "📍 Log: $LOG_FILE"
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
    echo ""
    echo "⚠️  Timeout: No input received. Exiting."
    log "Action timeout: No input received"
fi

echo ""
echo "╔═══════════════════════════════════╗"
echo "║          ✓ Done                  ║"
echo "║     Exiting in 2 seconds...       ║"
echo "╚═══════════════════════════════════╝"
sleep 2
echo ""
echo "✅ Action Complete"
echo "=================================="
exit 0