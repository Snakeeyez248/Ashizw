# 🛡️ Ashizw - Shizuku Watchdog & Manager

> **Keep Shizuku alive, automatically.**

[![Platform](https://img.shields.io/badge/Platform-Android-green)]()
[![Root](https://img.shields.io/badge/Root-Required-red)]()

**Author:** [Ghulam Qadar](https://github.com/GQ248)

---

## 📖 Description
**Ashizw** is a universal Magisk/KernelSU module designed to ensure **Shizuku** stays running permanently. It acts as a background watchdog, automatically restarting Shizuku if it crashes or stops unexpectedly. It also provides a powerful CLI and interactive menu for seamless management via Termux.

## ✨ Features
- 👍 **Watchdog Service:** Monitors Shizuku status at configurable intervals (Default: 30min)
- 🚀 **Auto-Start:** Automatically starts Shizuku after boot with a customizable delay (Default: 45s)
- 📱 **Interactive CLI:** User-friendly menu-driven management in Termux
- ⚡ **Quick Commands:** Fast CLI shortcuts for common actions
- 🧹 **Clean Uninstall:** Completely removes all configurations and logs upon module removal

## 📦 Installation
1. Download the latest `ashizw.zip` module file
2. Open your root manager (Magisk, KernelSU, or APatch)
3. Navigate to the **Modules** section
4. Tap **Install from Storage** and select the zip file
5. **Reboot** your device

## 🛠️ Usage

Open Termux and type:

    su
    ashizw

### Direct CLI Commands

| Command | Description |
|---------|-------------|
| `ashizw start` | Start Shizuku manually |
| `ashizw stop` | Stop Shizuku service |
| `ashizw status` | Check current status |
| `ashizw set_delay <s>` | Set Boot Delay (seconds) |
| `ashizw set_interval <s>` | Set Check Interval (seconds) |
| `ashizw menu` | Open Interactive Menu |
| `ashizw help` | Show help message |

## ⚙️ Configuration

- **Config File:** `/data/adb/.config/ashizw/config.json`
- **Log File:** `/data/adb/.config/ashizw/ashizw.log`
- **Default Boot Delay:** 45 seconds
- **Default Check Interval:** 1800 seconds (30 min)

## ⚠️ Requirements
- ✅ Root Access (Magisk / KernelSU / APatch)
- ✅ Shizuku App installed
- ✅ Termux (for management commands)

## 🐛 Troubleshooting
- **Shizuku not starting?** Check logs at `/data/adb/.config/ashizw/ashizw.log`
- **Command not found?** Ensure module is installed and rebooted
- **Permission denied?** Run commands with `su`

---

<div align="center">

**Made with ❤️ by Ghulam Qadar**

[Report Bugs](https://github.com/GQ248/ashizw/issues)

</div>
