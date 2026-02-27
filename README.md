# 🛡️ Ashizw - Shizuku Watchdog & Manager
**Author:** Ghulam Qadar  

## 📖 Description
Ashizw is a universal Magisk/KernelSU module that ensures Shizuku stays running. It acts as a watchdog, automatically restarting Shizuku if it crashes, and provides a powerful CLI for management.

## ✨ Features
- 👍 **Watchdog Service:** Checks Shizuku status every interval (default 30min).
- 🚀 **Auto-Start:** Starts Shizuku after reboot with a specific boot delay (default 45s).
- 📱 **Interactive CLI:** Menu-driven management in Termux.
- ⚡ **Shortcuts:** Fast CLI commands (e.g., `ashizw status` for status).
- 🧹 **Clean Uninstall:** Removes all configs upon removal.

## 🛠️ Usage (Termux)
Open Termux and type:
```bash
su
ashizw
```

### Option 2: Markdown Table (Better Mobile Readability)
This format adjusts better to different screen sizes on GitHub.

```markdown
### Ashizw Commands

| Command | Description |
| :--- | :--- |
| `ashizw start` | Start Shizuku |
| `ashizw stop` | Stop Shizuku |
| `ashizw status` | Check Status |
| `ashizw set_delay <s>` | Set Boot Delay (seconds) |
| `ashizw set_interval <s>` | Set Check Interval (seconds) |
| `ashizw menu` | Open Interactive Menu |
| `ashizw help` | Show this help |
## ⚙️ Configuration
Config file location: `/data/adb/.config/ashizw/config.json`
- **Boot Delay:** Time to wait after boot before starting (Default: 45s).
- **Check Interval:** How often to check heartbeat (Default: 1800s).

## 📝 Logs
Logs are stored at: `/data/adb/.config/ashizw/ashizw.log`

## ⚠️ Requirements
- Root Access (Magisk / KernelSU / APatch)
- Shizuku App installed.

---
**Made with ❤️ by Ghulam Qadar**
