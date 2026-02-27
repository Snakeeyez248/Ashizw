# 🛡️ Ashizw - Changelog

> Shizuku Watchdog & Manager for KernelSU / APatch / Magisk  
> **Author:** Ghulam Qadar 🇵🇰

---

## 🔖 v1.1 - Action Screen Fixes

### 🐛 Fixed
- Action button output now visible in KernelSU Manager
- Messages stay on screen for 3 seconds (readable!)
- Clear error messages with emojis when start/stop fails

### ✨ Improved
- Better feedback when `libshizuku.so` is not found
- Dynamic status updates during action execution
- Cleaner output formatting in action screen

---

## 🔖 v1.0 - Initial Release

### ✨ Features
- 💓 **Watchdog Service**: Auto-checks Shizuku status every interval (default: 30 min)
- 🚀 **Auto-Start**: Starts Shizuku after boot with configurable delay (default: 45s)
- 📱 **Interactive Termux Menu**: Clean numbered menu
- ⚡ **CLI Shortcuts**: 
  - `ashizw start` / `ashizw r` → Start Shizuku
  - `ashizw stop` / `ashizw k` → Stop Shizuku  
  - `ashizw status` / `ashizw s` → Check status
  - `ashizw menu` / `ashizw m` → Open interactive menu
- 🧹 **Clean Uninstall**: Removes all configs when module is removed
- ✅ **KernelSU Dynamic Status**: Live status shown in manager (`💓 Running` / `⚠️ Stopped`)
- ⚙️ **Configurable Settings**: 
  - Boot delay (seconds)
  - Check interval (seconds)
  - Stored in `/data/adb/.config/ashizw/config.json`
- 🌐 **Universal Compatibility**: Works on arm64, arm32, x86, x86_64
- 📝 **Detailed Logging**: All actions logged to `/data/adb/.config/ashizw/ashizw.log`

### 🛠️ Usage
```bash
su
ashizw              # Open interactive menu
ashizw start        # Start Shizuku manually
ashizw stop         # Stop Shizuku manually  
ashizw status       # Check if Shizuku is running
ashizw set_delay 60 # Set boot delay to 60 seconds
ashizw set_interval 3600 # Set check interval to 1 hour
