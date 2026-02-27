#!/system/bin/sh

MODPATH=${0%/*}
MODULE_ID="ashizw"

echo "=================================="
echo "   🛡️  Ashizw Installer  🛡️"
echo "   Author: Ghulam Qadar"
echo "=================================="

# Set permissions immediately
echo "⚙️ Setting permissions..."
chmod 755 "$MODPATH/system/bin/ashizw"
chmod 755 "$MODPATH/service.sh"
chmod 755 "$MODPATH/post-fs-data.sh"
chmod 755 "$MODPATH/action.sh"
chmod 755 "$MODPATH/uninstall.sh"
chmod 644 "$MODPATH/README.md"

# Create Config Dir Early
mkdir -p "/data/adb/.config/ashizw"

# Set initial dynamic status for KernelSU Manager
if command -v ksud >/dev/null 2>&1; then
    if pidof shizuku_server >/dev/null 2>&1; then
        ksud module config set override.description "💓 Shizuku Running | Watchdog Active"
    else
        ksud module config set override.description "⚠️ Shizuku Stopped | Tap Action to Start"
    fi
fi

echo "✅ Installation Complete!"
echo "💡 Reboot recommended to start Watchdog service."
echo "=================================="