#!/system/bin/sh

MODDIR=${0%/*}
CONFIG_DIR="/data/adb/.config/ashizw"
CONFIG_FILE="$CONFIG_DIR/config.json"
LOG_FILE="$CONFIG_DIR/ashizw.log"

# Create directories
mkdir -p "$CONFIG_DIR"

# Create default config if not exists
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" <<EOF
{
  "boot_delay": 45,
  "check_interval": 1800
}
EOF
    echo "[*] $(date): Config initialized with defaults." >> "$LOG_FILE"
fi

# Ensure binaries are executable
chmod 755 "$MODDIR/system/bin/ashizw"

# Ensure log file exists
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"