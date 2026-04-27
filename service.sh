#!/system/bin/sh

MODDIR=${0%/*}
CONFIG_DIR="/data/adb/.config/ashizw"
CONFIG_FILE="$CONFIG_DIR/config.json"
LOG_FILE="$CONFIG_DIR/ashizw.log"
RELOAD_FLAG="$CONFIG_DIR/reload.flag"
# Cache file: stores the resolved libshizuku.so path so we don't re-run find every time
LIB_CACHE="$CONFIG_DIR/lib_cache"
MODULE_ID="ashizw"

# Max log lines before rotation kicks in
LOG_MAX_LINES=500

log() {
    echo "[*] $(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
    rotate_log
}

rotate_log() {
    # Count lines; if over limit, keep only the last LOG_MAX_LINES lines
    line_count=$(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)
    if [ "$line_count" -gt "$LOG_MAX_LINES" ]; then
        tmp="${LOG_FILE}.tmp"
        tail -n "$LOG_MAX_LINES" "$LOG_FILE" > "$tmp" && mv "$tmp" "$LOG_FILE"
    fi
}

update_ksu_status() {
    status_msg="$1"
    if command -v ksud >/dev/null 2>&1; then
        ksud module config set override.description "$status_msg" 2>/dev/null || true
    fi
}

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

reload_config() {
    BOOT_DELAY=$(get_config "boot_delay" "45")
    CHECK_INTERVAL=$(get_config "check_interval" "1800")
    log "🔄 Config reloaded: Delay=${BOOT_DELAY}s, Interval=${CHECK_INTERVAL}s"
}

# ---------------------------------------------------------------
# find_lib: resolve libshizuku.so path with caching
#   - On first call (or after cache is invalidated), uses 'find'
#     with a 5-second timeout so a slow /data/app scan never
#     blocks the watchdog loop for a long time.
#   - On subsequent calls the cached path is verified quickly
#     with [ -f ], which is near-instant.
# ---------------------------------------------------------------
find_lib() {
    # 1. Fast path: cache hit
    if [ -f "$LIB_CACHE" ]; then
        cached=$(cat "$LIB_CACHE")
        if [ -n "$cached" ] && [ -f "$cached" ]; then
            echo "$cached"
            return 0
        else
            # Cache is stale (app updated/uninstalled), clear it
            rm -f "$LIB_CACHE"
        fi
    fi

    # 2. Slow path: scan /data/app with a hard 5-second timeout
    #    'timeout' is available in Android's toybox/busybox
    result=$(timeout 5 find /data/app/ -type f -name "libshizuku.so" 2>/dev/null | head -n 1)

    if [ -n "$result" ]; then
        echo "$result" > "$LIB_CACHE"
        echo "$result"
        return 0
    fi

    return 1
}

# ---------------------------------------------------------------
# restart_shizuku: attempt to launch Shizuku with exponential
#   back-off on consecutive failures so we don't spam the log
#   or drain the battery with tight retry loops.
#
#   Attempt delays: 30s → 60s → 120s → 240s → 480s (cap 480s)
# ---------------------------------------------------------------
FAIL_COUNT=0

restart_shizuku() {
    update_ksu_status "🔄 Ashizw: Restarting Shizuku..."

    LIB_PATH=$(find_lib)
    if [ -z "$LIB_PATH" ]; then
        log "ERROR: libshizuku.so not found! (find timed-out or Shizuku not installed)"
        update_ksu_status "❌ Ashizw: libshizuku.so Not Found"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi

    log "Located: $LIB_PATH — launching..."
    chmod 755 "$LIB_PATH" 2>/dev/null
    "$LIB_PATH"
    RET=$?

    if [ "$RET" -eq 0 ]; then
        log "SUCCESS: Shizuku restored by Ashizw."
        update_ksu_status "✅ Ashizw: Shizuku Restored"
        sleep 3
        update_ksu_status "💓 Shizuku Running | Watchdog Active ✅"
        FAIL_COUNT=0   # reset back-off counter on success
        return 0
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        log "FAILED: Exit code $RET (failure #${FAIL_COUNT})"
        update_ksu_status "⚠️ Ashizw: Start Failed (Code: $RET, Attempt: $FAIL_COUNT)"

        # Exponential back-off: 30 * 2^(n-1), capped at 480s
        backoff=$((30 * (1 << (FAIL_COUNT - 1))))
        [ "$backoff" -gt 480 ] && backoff=480
        log "⏳ Back-off: waiting ${backoff}s before next attempt..."
        sleep "$backoff"
        return 1
    fi
}

# ---------------------------------------------------------------
# Chunked sleep helper — wakes every 10s to check reload flag
# ---------------------------------------------------------------
chunked_sleep() {
    REMAINING=$1
    while [ "$REMAINING" -gt 0 ]; do
        if [ -f "$RELOAD_FLAG" ]; then
            rm -f "$RELOAD_FLAG" 2>/dev/null
            reload_config
            REMAINING=$CHECK_INTERVAL
            log "⚡ Config changed mid-sleep! New interval: ${CHECK_INTERVAL}s"
            update_ksu_status "💓 Shizuku Running | Watchdog Active ✅"
        fi
        CHUNK=10
        [ "$REMAINING" -lt "$CHUNK" ] && CHUNK=$REMAINING
        sleep "$CHUNK"
        REMAINING=$((REMAINING - CHUNK))
    done
}

# ============================================================
# MAIN
# ============================================================
log "🚀 Ashizw Service Started"
reload_config
log "⚙️ Boot Delay: ${BOOT_DELAY}s | Interval: ${CHECK_INTERVAL}s"
update_ksu_status "⏳ Ashizw Starting... (Delay: ${BOOT_DELAY}s)"

(
    sleep "$BOOT_DELAY"
    update_ksu_status "💓 Shizuku Running | Watchdog Active ✅"

    while true; do
        # Check reload flag
        if [ -f "$RELOAD_FLAG" ]; then
            rm -f "$RELOAD_FLAG" 2>/dev/null
            reload_config
            update_ksu_status "💓 Shizuku Running | Watchdog Active ✅"
        fi

        # Check Shizuku
        if pidof shizuku_server >/dev/null 2>&1; then
            log "💓 Heartbeat OK | Shizuku running (Interval: ${CHECK_INTERVAL}s)"
            update_ksu_status "💓 Shizuku Running | Watchdog Active ✅"
            FAIL_COUNT=0  # reset if it recovered on its own
        else
            log "⚠️ Shizuku missing. Deploying Ashizw..."
            restart_shizuku
        fi

        chunked_sleep "$CHECK_INTERVAL"
    done
) &

exit 0
