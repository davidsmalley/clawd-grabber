import Cocoa
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()
    let hotkeyManager = HotkeyManager()
    let screenshotService = ScreenshotService()
    let claudeService = ClaudePasteService()
    let downloadsWatcher = DownloadsWatcher()

    func applicationDidFinishLaunching(_ notification: Notification) {
        checkAccessibility()
        wireUpCallbacks()

        if appState.isEnabled {
            hotkeyManager.start()
            downloadsWatcher.start()
        }
    }

    private func wireUpCallbacks() {
        hotkeyManager.onHotkeyPressed = { [weak self] in
            guard let self, self.appState.isEnabled else { return }
            self.screenshotService.captureRegion { url in
                guard let url else { return }
                self.claudeService.pasteImageIntoClaude(from: url)
            }
        }

        downloadsWatcher.onNewScreenshot = { [weak self] url in
            guard let self, self.appState.isEnabled else { return }
            self.claudeService.pasteImageIntoClaude(from: url)
        }
    }

    func setEnabled(_ enabled: Bool) {
        if enabled {
            hotkeyManager.start()
            downloadsWatcher.start()
        } else {
            hotkeyManager.stop()
            downloadsWatcher.stop()
        }
    }

    private func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        if !AXIsProcessTrustedWithOptions(options) {
            // The system will show the accessibility prompt automatically
        }
    }
}
