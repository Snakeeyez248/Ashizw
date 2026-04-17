# 🛡️ Ashizw - Shizuku Watchdog & Manager

> **Keep Shizuku alive, automatically.**

[![Platform](https://img.shields.io/badge/Platform-Android-green)]()
[![Root](https://img.shields.io/badge/Root-Required-red)]()

**Author:** [Ghulam Qadar](https://github.com/Snakeeyez248)

---

## 📖 Description
**Ashizw** is a universal Magisk/KernelSU module designed to ensure **Shizuku** stays running permanently. It acts as a background watchdog, automatically restarting Shizuku if it crashes or stops unexpectedly. 

Now featuring a **beautiful WebUI dashboard** inside KernelSU Manager for one-tap control, real-time monitoring, and live logs — no Termux required! Plus a powerful CLI and interactive menu for advanced users who prefer terminal management.

## ✨ Features
- 👍 **Watchdog Service:** Monitors Shizuku status at configurable intervals (Default: 30min)
- 🚀 **Auto-Start:** Automatically starts Shizuku after boot with a customizable delay (Default: 45s)
- 🌐 **WebUI Dashboard** *(v1.4+)*: 
  - Real-time status badge (🟢 Running / 🔴 Stopped)
  - One-tap Start/Stop Shizuku with instant feedback
  - Live log viewer with auto-refresh, color-coded entries, and scroll controls
  - Configurable boot delay & check interval with live validation
  - **🎨 Theme Switcher** *(v1.5+)*: Choose between **Dark**, **Light**, or **Auto** (System) themes
  - Responsive design optimized for all devices
- 📱 **Interactive CLI:** User-friendly menu-driven management in Termux
- ⚡ **Quick Commands:** Fast CLI shortcuts for common actions (`ashizw start`, `ashizw status`, etc.)
- 🔘 **KernelSU Action Button** *(v1.5+)*: 
  - Clean, minimal interface with volume key controls
  - `Volume Up` → Start/Stop Shizuku (with confirmation)
  - `Volume Down` → Directly opens Shizuku app (no picker menu)
- 🖼️ **Module Banner Support** *(v1.4+)*: Displays artwork in supported managers (✅ KernelSU Next)
- 🧹 **Clean Uninstall:** Completely removes all configurations and logs upon module removal

## 📦 Installation
### Basic Install
1. Download the latest `Ashizw-v1.5.zip` module file from [Releases](https://github.com/Snakeeyez248/Ashizw/releases)
2. Open your root manager (Magisk, KernelSU, or APatch)
3. Navigate to the **Modules** section
4. Tap **Install from Storage** and select the zip file
5. **Reboot** your device

### Post-Install Setup
#### 🔹 Using WebUI (KernelSU Manager)
1. Open **KernelSU Manager** → **Modules** → **Ashizw**
2. Tap the **WebUI** tab (or globe icon 🌐)
3. Enjoy the dashboard:
   - 🟢 Status badge shows Shizuku state instantly
   - ⚡ Start/Stop buttons with visual feedback
   - 📝 Logs tab with live auto-refresh
   - ⚙️ Configure intervals without editing files
   - 🎨 **Theme Switcher**: Toggle between Dark, Light, or Auto themes in the header

#### 🔹 Using KernelSU Action Button *(v1.5+)*
1. Open **KernelSU Manager** → **Modules** → **Ashizw**
2. Tap the **Action Button** (⚡ icon)
3. Wait for the action screen to appear
4. Press a volume key within 10 seconds:
   - **Volume Up** → Start/Stop Shizuku (confirms before executing)
   - **Volume Down** → Opens Shizuku app directly
5. Screen exits automatically after action completes

#### 🔹 Using CLI (Termux)
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
> **Note:** Complete hiding of OverlayFS signatures requires SuSFS or similar kernel-level modules. Ashizw does not modify mount structures.
> 
> *My setup (working without detection issues):*  
> - Root Manager: SukiSu Ultra v4.1.2  
> - Mount Mode: Hybrid Mount (magic mount default)  
> - Hiding Module: SuSFS enabled  
> - Result: ✅ No OverlayFS warnings in Hunter/Duck Detector
## 🐛 Troubleshooting
- **Shizuku not starting?** Check logs at `/data/adb/.config/ashizw/ashizw.log`
- **Command not found?** Ensure module is installed and rebooted
- **Permission denied?** Run commands with `su`

---

<div align="center">

**Made with ❤️ by Ghulam Qadar**

[Report Bugs](https://github.com/Snakeeyez248/ashizw/issues)

</div>

---

👋 **A Personal Note from the Developer**

> Hi! I'm Ghulam Qadar. I want to be honest: **I don't know how to code**. 💙
> 
> I just had an idea to keep Shizuku running automatically, and I used **Qwen AI** to help me write the code. Since AI wrote it, **don't expect too much**, but I tested it thoroughly and I'm using it on my own device (Redmi 14C, HyperOS) right now - working perfectly! 🎉
> 
> **P.S.** If you're wondering what "Ashizw" means - it's short for **"A Shizuku Watchdog"**! 🔍
> 
> This is my first public module, so:
> - 🙏 If you have any advice, I'd love to hear it!
> - 🐛 If you find any bugs, please report them!
> - ✨ If you have feature ideas, let me know!
> 
> Every contribution helps me learn and make this project better. Thank you for trying Ashizw! ❤️

