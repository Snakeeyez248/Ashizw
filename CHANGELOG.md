# 🛡️ Ashizw - Changelog

> Shizuku Watchdog & Manager for KernelSU / APatch / Magisk  
> **Author:** Ghulam Qadar 🇵🇰

---

# Ashizw v1.4 - New WebUI Support

## 🎉 New Features

### ✨ Full WebUI Management Interface
- Complete dashboard with real-time status monitoring
- One-tap Start/Stop Shizuku controls with instant visual feedback
- Configurable boot delay and check interval with live validation
- Dedicated Logs tab with:
  - Live auto-refresh
  - Manual refresh & clear buttons
  - Color-coded entries (✅ success, ❌ error, ⚠️ warning)
  - Floating scroll-to-top/bottom buttons
- Responsive dark theme


## 🛠️ Improvements

### WebUI Reliability
- Smart success detection: recognizes `✅`/`SUCCESS` in output even if exit code is non-zero
- Buffer-safe log loading: uses `tail -n 300` to stay within KernelSU exec limits
- HTML escaping: prevents XSS and ensures clean log rendering
- Graceful API fallback: shows warning if `ksu.exec` is unavailable

### User Experience
- Instant UI updates: status changes immediately on button press, then verifies with backend
- Persistent configuration: values load from `config.json` on startup
- Version display: reads actual version from `module.prop` dynamically

### Code Quality
- Modular JavaScript: separated concerns (exec, UI, logs, config)
- Error handling: all async operations wrapped in try/catch with user-friendly toasts

## ⚙️ Technical Notes
- Banner display depends on manager implementation (KSU Next ✅, others ⚠️)
- All commands execute via `/data/adb/modules/ashizw/system/bin/ashizw` for path consistency
- Log file path: `/data/adb/.config/ashizw/ashizw.log`

## 📦 Installation
1. Flash `ashizw-v1.4.zip` via KernelSU Manager
2. Grant root permission when prompted
3. Open Ashizw in manager → WebUI tab to access dashboard
4. (Optional) Add custom `banner.png` to module root for supported managers

---

> Made with ❤️ by Ghulam Qadar  
> License: GPL-3.0


## 🔖 v1.3 - Instant Config Reload

### ✨ New Feature
- Config changes now apply within ~10 seconds (no waiting for next cycle!)
- Service detects config updates via reload flag mechanism
- Chunked sleep allows responsive config reload without performance impact

### 🔧 Technical
- Added `/data/adb/.config/ashizw/reload.flag` for service-CLI communication
- Sleep loop checks for config changes every 10 seconds
- Config re-read triggered immediately when flag detected

### 🐛 Fixed
- No more waiting up to 30 minutes for interval changes to take effect
- More responsive user experience when tweaking settings

---

## 🔖 v1.2 - Config Reload Fix

### 🐛 Fixed
- Config changes now apply without reboot
- Watchdog service re-reads `check_interval` on every check cycle

### ✨ Improved
- No need to reboot after changing settings via CLI
- More responsive to user configuration updates

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
