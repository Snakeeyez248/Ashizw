// Ashizw WebUI - Final version with smart success detection and theme support

// Theme management
const THEME_STORAGE_KEY = 'ashizw_theme';
const THEME_ATTR = 'data-theme';

function getSystemTheme() {
    return window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark';
}

function applyTheme(theme) {
    if (theme === 'auto') {
        const systemTheme = getSystemTheme();
        document.documentElement.setAttribute(THEME_ATTR, systemTheme);
    } else {
        document.documentElement.setAttribute(THEME_ATTR, theme);
    }
}

function initTheme() {
    const savedTheme = localStorage.getItem(THEME_STORAGE_KEY) || 'auto';
    const themeSelect = document.getElementById('themeSelect');
    if (themeSelect) {
        themeSelect.value = savedTheme;
    }
    applyTheme(savedTheme);
}

function setupThemeListener() {
    const themeSelect = document.getElementById('themeSelect');
    if (!themeSelect) return;
    
    themeSelect.addEventListener('change', (e) => {
        const selectedTheme = e.target.value;
        localStorage.setItem(THEME_STORAGE_KEY, selectedTheme);
        applyTheme(selectedTheme);
    });
    
    // Listen for system theme changes when in auto mode
    window.matchMedia('(prefers-color-scheme: light)').addEventListener('change', () => {
        const currentTheme = localStorage.getItem(THEME_STORAGE_KEY) || 'auto';
        if (currentTheme === 'auto') {
            applyTheme('auto');
        }
    });
}

document.getElementById('statusText').innerText = 'Initialising...';
console.log('[Ashizw] Script started');

function execCommand(cmd) {
    return new Promise((resolve, reject) => {
        if (typeof ksu === 'undefined' || typeof ksu.exec !== 'function') {
            reject(new Error('KernelSU API not available'));
            return;
        }
        const callbackName = 'ksu_cb_' + Date.now() + '_' + Math.random().toString(36).substr(2);
        window[callbackName] = function(errno, stdout, stderr) {
            delete window[callbackName];
            // If exit code is non-zero but stdout contains success indicators, treat as success
            const output = stdout || '';
            if (errno !== 0 && (output.includes('SUCCESS') || output.includes('✅'))) {
                resolve(output); // Command actually succeeded
            } else if (errno === 0) {
                resolve(output);
            } else {
                reject(new Error(`Command failed (${errno}): ${stderr || stdout}`));
            }
        };
        try {
            ksu.exec(cmd, '{}', callbackName);
        } catch (e) {
            delete window[callbackName];
            reject(e);
        }
    });
}

function showToast(msg) {
    if (typeof ksu !== 'undefined' && typeof ksu.toast === 'function') {
        ksu.toast(msg);
    } else {
        console.log('[Toast]', msg);
    }
}

function switchTab(tabName) {
    document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    if (tabName === 'dashboard') {
        document.getElementById('dashboardTab').classList.add('active');
        document.getElementById('tabDashboardBtn').classList.add('active');
    } else if (tabName === 'logs') {
        document.getElementById('logsTab').classList.add('active');
        document.getElementById('tabLogsBtn').classList.add('active');
        loadLogs(true);
    }
}

function fetchModuleVersion() {
    execCommand('cat /data/adb/modules/ashizw/module.prop | grep "^version=" | cut -d= -f2')
        .then(result => {
            const version = result.trim() || 'unknown';
            document.getElementById('versionValue').textContent = version;
        })
        .catch(() => {
            document.getElementById('versionValue').textContent = '1.3';
        });
}

function checkStatus() {
    execCommand('/data/adb/modules/ashizw/system/bin/ashizw status')
        .then(result => {
            const output = String(result).trim();
            const dot = document.getElementById('statusDot');
            const text = document.getElementById('statusText');
            if (output.includes('RUNNING')) {
                dot.className = 'status-dot running';
                text.textContent = 'Running';
            } else if (output.includes('STOPPED')) {
                dot.className = 'status-dot stopped';
                text.textContent = 'Stopped';
            } else {
                dot.className = 'status-dot stopped';
                text.textContent = 'Unknown';
            }
        })
        .catch(err => {
            document.getElementById('statusDot').className = 'status-dot stopped';
            document.getElementById('statusText').textContent = 'Error';
            showToast('Status check failed: ' + err.message);
        });
}

function startShizuku() {
    // First check if Shizuku is already running
    execCommand('pidof shizuku_server')
        .then(pidResult => {
            // If pidof returns output, Shizuku is running
            if (pidResult && pidResult.trim().length > 0) {
                showToast('💓 Shizuku is already running');
                checkStatus();
                return;
            }
            // Not running, proceed with start
            showToast('Starting Shizuku...');
            return execCommand('/data/adb/modules/ashizw/system/bin/ashizw start');
        })
        .then(result => {
            if (!result) return; // Already running case
            // Extract success message from output
            const output = result.trim();
            // Look for a line containing SUCCESS or ✅
            const successMatch = output.match(/(✅|SUCCESS).*/);
            const msg = successMatch ? successMatch[0] : 'Shizuku started';
            showToast('✅ ' + msg);
            checkStatus();
            loadLogs();
        })
        .catch(err => {
            showToast('❌ Error: ' + err.message);
            checkStatus();
            loadLogs();
        });
}

function stopShizuku() {
    // First check if Shizuku is already stopped
    execCommand('pidof shizuku_server')
        .then(pidResult => {
            // If pidof returns no output, Shizuku is already stopped
            if (!pidResult || pidResult.trim().length === 0) {
                showToast('⚠️ Shizuku is already stopped');
                checkStatus();
                return;
            }
            // Running, proceed with stop
            showToast('Stopping Shizuku...');
            return execCommand('/data/adb/modules/ashizw/system/bin/ashizw stop');
        })
        .then(result => {
            if (!result) return; // Already stopped case
            showToast('✅ ' + (result || 'Stopped').trim());
            checkStatus();
            loadLogs();
        })
        .catch(err => {
            showToast('❌ Error: ' + err.message);
            checkStatus();
            loadLogs();
        });
}

function loadConfig() {
    execCommand('grep "boot_delay" /data/adb/.config/ashizw/config.json | sed "s/[^0-9]//g"')
        .then(boot => {
            const val = parseInt(boot, 10);
            if (!isNaN(val)) document.getElementById('bootDelay').value = val;
        })
        .catch(() => {});
    execCommand('grep "check_interval" /data/adb/.config/ashizw/config.json | sed "s/[^0-9]//g"')
        .then(interval => {
            const val = parseInt(interval, 10);
            if (!isNaN(val)) document.getElementById('checkInterval').value = val;
        })
        .catch(() => {});
}

function saveSettings() {
    const bootDelay = document.getElementById('bootDelay').value;
    const checkInterval = document.getElementById('checkInterval').value;
    if (!bootDelay || bootDelay < 1) {
        showToast('❌ Boot delay must be ≥1');
        return;
    }
    if (!checkInterval || checkInterval < 10) {
        showToast('❌ Check interval must be ≥10');
        return;
    }
    showToast('💾 Saving settings...');
    execCommand(`/data/adb/modules/ashizw/system/bin/ashizw set_delay ${bootDelay}`)
        .then(() => execCommand(`/data/adb/modules/ashizw/system/bin/ashizw set_interval ${checkInterval}`))
        .then(() => {
            showToast('✅ Settings saved!');
            loadConfig();
            loadLogs();
        })
        .catch(err => showToast('❌ Failed: ' + err.message));
}

function loadLogs(scrollToBottom = false) {
    const container = document.getElementById('logsContainer');
    const countSpan = document.getElementById('logsCount');
    container.innerHTML = '<div class="log-entry loading">Loading logs...</div>';
    execCommand('tail -n 300 /data/adb/.config/ashizw/ashizw.log')
        .then(result => {
            const logText = result || '';
            const lines = logText.split('\n').filter(line => line.trim() !== '');
            if (lines.length === 0) {
                container.innerHTML = '<div class="log-entry">No logs available</div>';
                countSpan.textContent = '0 entries';
                return;
            }
            container.innerHTML = lines.map(line => {
                let className = '';
                if (line.includes('ERROR') || line.includes('FAILED') || line.includes('❌')) className = 'error';
                else if (line.includes('SUCCESS') || line.includes('✅')) className = 'success';
                else if (line.includes('WARNING') || line.includes('⚠️')) className = 'warning';
                const clean = line.replace(/[^\x20-\x7E\u00A0-\uFFFF]/g, '');
                return `<div class="log-entry ${className}">${escapeHtml(clean)}</div>`;
            }).join('');
            countSpan.textContent = lines.length + ' entries';
            if (scrollToBottom) {
                container.scrollTop = container.scrollHeight;
            } else {
                container.scrollTop = container.scrollHeight;
            }
        })
        .catch(err => {
            container.innerHTML = '<div class="log-entry error">Failed to load logs: ' + err.message + '</div>';
            countSpan.textContent = '0 entries';
        });
}

function clearLogs() {
    execCommand('echo "" > /data/adb/.config/ashizw/ashizw.log')
        .then(() => {
            showToast('🗑️ Logs cleared');
            loadLogs(true);
        })
        .catch(err => showToast('❌ Failed to clear logs: ' + err.message));
}

function scrollToTop() {
    document.getElementById('logsContainer').scrollTop = 0;
}

function scrollToBottom() {
    const c = document.getElementById('logsContainer');
    c.scrollTop = c.scrollHeight;
}

function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function checkApiAvailability() {
    const available = typeof ksu !== 'undefined' && typeof ksu.exec === 'function';
    const warning = document.getElementById('apiWarning');
    if (available) {
        warning.classList.remove('show');
    } else {
        warning.classList.add('show');
        document.getElementById('statusDot').className = 'status-dot stopped';
        document.getElementById('statusText').textContent = 'API missing';
    }
    return available;
}

document.addEventListener('DOMContentLoaded', () => {
    console.log('[Ashizw] DOM ready');
    // Initialize theme first
    initTheme();
    setupThemeListener();
    
    checkApiAvailability();
    document.getElementById('tabDashboardBtn').addEventListener('click', () => switchTab('dashboard'));
    document.getElementById('tabLogsBtn').addEventListener('click', () => switchTab('logs'));
    document.getElementById('startBtn').addEventListener('click', startShizuku);
    document.getElementById('stopBtn').addEventListener('click', stopShizuku);
    document.getElementById('refreshStatusBtn').addEventListener('click', checkStatus);
    document.getElementById('saveConfigBtn').addEventListener('click', saveSettings);
    document.getElementById('refreshLogsBtn').addEventListener('click', () => loadLogs(true));
    document.getElementById('clearLogsBtn').addEventListener('click', clearLogs);
    document.getElementById('scrollTopBtn').addEventListener('click', scrollToTop);
    document.getElementById('scrollBottomBtn').addEventListener('click', scrollToBottom);
    fetchModuleVersion();
    setTimeout(() => {
        console.log('[Ashizw] Running initial data loads');
        checkStatus();
        loadConfig();
        loadLogs(true);
    }, 1000);
    setInterval(checkStatus, 30000);
    showToast('Ashizw WebUI loaded');
});