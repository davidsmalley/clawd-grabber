import Cocoa
import UserNotifications

class ClaudePasteService {
    private let claudeBundleID = "com.anthropic.claudefordesktop"

    func pasteImageIntoClaude(from url: URL, trashAfter: Bool = true) {
        guard copyImageToClipboard(from: url) else { return }
        guard activateClaude() else { return }

        // Delay to let Claude come to foreground and focus its input
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.simulatePaste()

            if trashAfter {
                // Delay before trashing to ensure paste completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    try? FileManager.default.trashItem(at: url, resultingItemURL: nil)
                }
            }
        }
    }

    private func copyImageToClipboard(from url: URL) -> Bool {
        guard let image = NSImage(contentsOf: url) else { return false }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.writeObjects([image])
        return true
    }

    private func activateClaude() -> Bool {
        let apps = NSRunningApplication.runningApplications(
            withBundleIdentifier: claudeBundleID)
        guard let claude = apps.first else {
            showNotification(
                title: "ClawGrabber",
                body: "Claude Desktop is not running.")
            return false
        }
        return claude.activate()
    }

    private func simulatePaste() {
        // 'v' keyCode = 9
        let source = CGEventSource(stateID: .combinedSessionState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    private func showNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
