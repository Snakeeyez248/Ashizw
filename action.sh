#!/system/bin/sh

CONFIG_DIR="/data/adb/.config/ashizw"
LOG_FILE="$CONFIG_DIR/ashizw.log"
MODULE_ID="ashizw"

# Toast Function
show_toast() {
    command -v toast >/dev/null 2>&1 && toast "$1"
}

# Update KernelSU dynamic status
update_ksu_status() {
    status_msg="$1"
    if command -v ksud >/dev/null 2>&1; then
        ksud module config set override.description "$status_msg"
    fi
}

log() {
    echo "[*] $(date '+%Y-%m-%d %H:%M:%S'): [ACTION] $1" >> "$LOG_FILE"
}

start_shizuku() {
    log " Starting Shizuku via Action..."
    update_ksu_status " Ashizw: Starting Shizuku..."
    
    LIB_PATH=$(find /data/app/ -type f -name "libshizuku.so" 2>/dev/null | head -n 1)

    if [ -z "$LIB_PATH" ]; then
        log "ERROR: libshizuku.so not found!"
        show_toast " Ashizw: .so not found"
        update_ksu_status " Ashizw: libshizuku.so Not Found"
        return 1
    else
        log "Located: $LIB_PATH"
        chmod 755 "$LIB_PATH" 2>/dev/null
        "$LIB_PATH" &
        RET=$?
        if [ "$RET" -eq 0 ]; then
            log "SUCCESS: Shizuku restored by Ashizw."
            show_toast " Ashizw: Started"
            update_ksu_status " Shizuku Running | Started via Action"
            sleep 3
            update_ksu_status " Shizuku Running | Watchdog Active "
        else
            log "FAILED: Exit code $RET"
            show_toast " Ashizw: Start Failed"
            update_ksu_status " Ashizw: Start Failed (Code: $RET)"
        fi
    fi
}

if pidof shizuku_server >/dev/null 2>&1; then
    log " Stopping Shizuku via Action..."
    update_ksu_status " Ashizw: Stopping Shizuku..."
    pkill -f shizuku_server
    pkill -f shizuku
    sleep 2
    if ! pidof shizuku_server >/dev/null 2>&1; then
        log " Shizuku Stopped Successfully"
        show_toast " Ashizw: Stopped"
        update_ksu_status " Shizuku Stopped | Tap Action to Start"
    else
        log " Failed to stop Shizuku"
        show_toast " Ashizw: Stop Failed"
        update_ksu_status " Ashizw: Stop Failed"
    fi
else
    start_shizuku
fi