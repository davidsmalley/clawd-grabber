import Cocoa

class HotkeyManager {
    private var monitor: Any?
    var onHotkeyPressed: (() -> Void)?

    func start() {
        guard monitor == nil else { return }
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // F13: keyCode 105 (no modifiers needed)
            if event.keyCode == 105 {
                self?.onHotkeyPressed?()
            }
        }
    }

    func stop() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
    }
}
