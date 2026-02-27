#!/system/bin/sh

MODPATH=${0%/*}

echo "=================================="
echo "   🛡️  Ashizw Installer  🛡️"
echo "   Author: Ghulam Qadar"
echo "=================================="

# Set permissions immediately
echo "⚙️ Setting permissions..."
chmod 755 "$MODPATH/system/bin/ashizw" 2>/dev/null
chmod 755 "$MODPATH/service.sh" 2>/dev/null
chmod 755 "$MODPATH/post-fs-data.sh" 2>/dev/null
chmod 755 "$MODPATH/action.sh" 2>/dev/null
chmod 755 "$MODPATH/uninstall.sh" 2>/dev/null

# Create Config Dir Early
mkdir -p "/data/adb/.config/ashizw" 2>/dev/null

# Set initial dynamic status for KernelSU Manager
# IMPORTANT: Suppress errors to prevent installation failure
if command -v ksud >/dev/null 2>&1; then
    if pidof shizuku_server >/dev/null 2>&1; then
        ksud module config set override.description "💓 Shizuku Running | Watchdog Active" 2>/dev/null || true
    else
        ksud module config set override.description "⚠️ Shizuku Stopped | Tap Action to Start" 2>/dev/null || true
    fi
fi

echo "✅ Installation Complete!"
echo "💡 Reboot recommended to start Watchdog service."
echo "=================================="

# Ensure script exits successfully
exit 0