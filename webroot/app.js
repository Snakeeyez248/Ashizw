// Ashizw WebUI - Final version with smart success detection and theme support

// Theme management using cookies (more resilient than localStorage)
const THEME_COOKIE_NAME = 'ashizw_theme';
const THEME_ATTR = 'data-theme';

function setCookie(name, value, days) {
    const expires = new Date(Date.now() + days * 864e5).toUTCString();
    document.cookie = name + '=' + encodeURIComponent(value) + '; expires=' + expires + '; path=/; SameSite=Strict';
}

function getCookie(name) {
    const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
    return match ? decodeURIComponent(match[2]) : null;
}

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
    const savedTheme = getCookie(THEME_COOKIE_NAME) || 'auto';
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
        setCookie(THEME_COOKIE_NAME, selectedTheme, 365); // 1 year expiry
        applyTheme(selectedTheme);
    });
    
    // Listen for system theme changes when in auto mode
    window.matchMedia('(prefers-color-scheme: light)').addEventListener('change', () => {
        const currentTheme = getCookie(THEME_COOKIE_NAME) || 'auto';
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
    // First check if Shizuku is already running using pidof
    execCommand('pidof shizuku_server >/dev/null 2>&1 && echo "running" || echo "stopped"')
        .then(stateResult => {
            const state = (stateResult || '').trim();
            
            // If already running, show message and skip
            if (state === 'running') {
                showToast('💓 Shizuku is already running');
                checkStatus();
                return Promise.resolve(null);
            }
            
            // Not running, proceed with start
            showToast('🚀 Starting Shizuku...');
            return execCommand('/data/adb/modules/ashizw/system/bin/ashizw start');
        })
        .then(result => {
            if (result === null) return; // Already running case, skip
            
            // Extract success message from output
            const output = (result || '').trim();
            
            // Look for success indicators
            if (output.includes('SUCCESS') || output.includes('✅') || output.includes('already running')) {
                const successMatch = output.match(/(✅|SUCCESS|💓).*/);
                const msg = successMatch ? successMatch[0] : 'Shizuku started';
                showToast('✅ ' + msg);
            } else if (output.includes('FAILED') || output.includes('❌') || output.includes('ERROR')) {
                const errorMatch = output.match(/(❌|FAILED|ERROR).*/);
                const errMsg = errorMatch ? errorMatch[0] : 'Start failed';
                showToast('❌ ' + errMsg);
            } else {
                // Default success if no error indicators
                showToast('✅ Shizuku started');
            }
            
            checkStatus();
            loadLogs();
        })
        .catch(err => {
            const errMsg = err.message || 'Unknown error';
            // Check if error message contains success indicators (fallback)
            if (errMsg.includes('SUCCESS') || errMsg.includes('✅')) {
                showToast('✅ Command succeeded');
            } else {
                showToast('❌ Error: ' + errMsg);
            }
            checkStatus();
            loadLogs();
        });
}

function stopShizuku() {
    // First check if Shizuku is already stopped using pidof
    execCommand('pidof shizuku_server >/dev/null 2>&1 && echo "running" || echo "stopped"')
        .then(stateResult => {
            const state = (stateResult || '').trim();
            
            // If already stopped, show message and skip
            if (state === 'stopped') {
                showToast('⚠️ Shizuku is already stopped');
                checkStatus();
                return Promise.resolve(null);
            }
            
            // Running, proceed with stop
            showToast('🛑 Stopping Shizuku...');
            return execCommand('/data/adb/modules/ashizw/system/bin/ashizw stop');
        })
        .then(result => {
            if (result === null) return; // Already stopped case, skip
            
            // Extract result message from output
            const output = (result || '').trim();
            
            // Look for success/failure indicators
            if (output.includes('SUCCESS') || output.includes('✅') || output.includes('Stopped Successfully')) {
                const successMatch = output.match(/(✅|SUCCESS).*/);
                const msg = successMatch ? successMatch[0] : 'Shizuku stopped';
                showToast('✅ ' + msg);
            } else if (output.includes('FAILED') || output.includes('❌') || output.includes('ERROR')) {
                const errorMatch = output.match(/(❌|FAILED|ERROR).*/);
                const errMsg = errorMatch ? errorMatch[0] : 'Stop failed';
                showToast('❌ ' + errMsg);
            } else if (output.includes('already stopped')) {
                showToast('⚠️ Shizuku is already stopped');
            } else {
                // Default success if no error indicators
                showToast('✅ Shizuku stopped');
            }
            
            checkStatus();
            loadLogs();
        })
        .catch(err => {
            const errMsg = err.message || 'Unknown error';
            // Check if error message contains success indicators (fallback)
            if (errMsg.includes('SUCCESS') || errMsg.includes('✅')) {
                showToast('✅ Command succeeded');
            } else {
                showToast('❌ Error: ' + errMsg);
            }
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
// Auto-refresh logs every 15 seconds when tab is visible
let logsAutoRefreshInterval = null;

function startLogsAutoRefresh() {
    if (logsAutoRefreshInterval) clearInterval(logsAutoRefreshInterval);
    logsAutoRefreshInterval = setInterval(() => {
        const logsTab = document.getElementById('logsTab');
        if (logsTab && logsTab.classList.contains('active')) {
            // Only auto-scroll if user was already at bottom
            const container = document.getElementById('logsContainer');
            const wasAtBottom = container.scrollTop + container.clientHeight >= container.scrollHeight - 10;
            loadLogs(wasAtBottom);
        }
    }, 15000);
}

// Pause auto-refresh when page is hidden (visibilitychange)
document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
        if (logsAutoRefreshInterval) {
            clearInterval(logsAutoRefreshInterval);
            logsAutoRefreshInterval = null;
        }
    } else {
        startLogsAutoRefresh();
    }
});

// Start auto-refresh after DOM is ready
setTimeout(startLogsAutoRefresh, 2000);

// API retry with exponential backoff - poll for ksu.exec up to 6 times (3 seconds total)
async function waitForApi(maxRetries = 6, delayMs = 500) {
    for (let i = 0; i < maxRetries; i++) {
        if (typeof ksu !== 'undefined' && typeof ksu.exec === 'function') {
            return true;
        }
        console.log('[Ashizw] Waiting for KernelSU API... attempt', i + 1);
        await new Promise(resolve => setTimeout(resolve, delayMs));
    }
    return false;
}

// Re-init with API wait on DOMContentLoaded
(function() {
    const originalListener = document.addEventListener;
    document.addEventListener('DOMContentLoaded', async () => {
        const apiAvailable = await waitForApi();
        if (!apiAvailable) {
            console.warn('[Ashizw] KernelSU API not available after retries');
            document.getElementById('apiWarning').classList.add('show');
        }
    }, true);
})();
