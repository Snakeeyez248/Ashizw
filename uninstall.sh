#!/system/bin/sh

CONFIG_DIR="/data/adb/.config/ashizw"
MODULE_ID="ashizw"

echo "🧹 Ashizw Uninstalling..."

# Clear dynamic status config
if command -v ksud >/dev/null 2>&1; then
    ksud module config delete override.description 2>/dev/null
fi

# Remove config directory
if [ -d "$CONFIG_DIR" ]; then
    rm -rf "$CONFIG_DIR"
    echo "✅ Config directory removed."
else
    echo "ℹ️  Config directory not found."
fi

echo "✅ Ashizw completely removed."
echo "💡 Note: Shizuku app data remains untouched."