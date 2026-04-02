import SwiftUI
import ServiceManagement

@main
struct ClawGrabberApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        MenuBarExtra {
            MenuContent(delegate: delegate)
        } label: {
            MenuBarLabel(appState: delegate.appState)
        }
    }
}

struct MenuBarLabel: View {
    @ObservedObject var appState: AppState

    var body: some View {
        Image(systemName: appState.isEnabled ? "camera.fill" : "camera")
    }
}

struct MenuContent: View {
    @ObservedObject var appState: AppState
    let delegate: AppDelegate

    init(delegate: AppDelegate) {
        self.delegate = delegate
        self.appState = delegate.appState
    }

    var body: some View {
        Toggle("Enabled", isOn: $appState.isEnabled)
            .onChange(of: appState.isEnabled) { enabled in
                delegate.setEnabled(enabled)
            }

        Divider()

        Text("F13 to capture")
            .foregroundColor(.secondary)

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
