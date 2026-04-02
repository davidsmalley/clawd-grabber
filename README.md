# ClawdGrabber

A macOS menu bar utility that captures screenshots and pastes them directly into [Claude Desktop](https://claude.ai/download). It also watches your Downloads folder for screenshots sent from your iPhone (via AirDrop) and does the same.

## Why?

When working with Claude, you often need to share screenshots of apps, websites, or error states. The typical workflow is:

1. Take a screenshot (lands on Desktop or Downloads)
2. Switch to Claude
3. Drag or paste the image
4. Forget about the screenshot file, which clutters your Desktop/Downloads forever

ClawdGrabber collapses this to a single keypress. Screenshots go straight into Claude's prompt input and the temporary file is moved to Trash automatically.

## Features

- **F13 hotkey** to capture a screen region and paste it directly into Claude Desktop
- **Downloads folder watcher** that detects iPhone screenshots (via AirDrop) and auto-pastes them into Claude
- **Menu bar toggle** to quickly enable/disable (so you can receive iPhone screenshots normally when needed)
- **Auto-cleanup** — original files are moved to Trash after pasting
- **Persisted state** — remembers your on/off preference across launches

## Requirements

- macOS 13.0+
- [Claude Desktop](https://claude.ai/download)
- Accessibility permission (for global hotkey and simulated paste)

## Setup

1. Clone the repo and open `ClawdGrabber.xcodeproj` in Xcode
2. Set your own **Team** and **Bundle Identifier** in Signing & Capabilities
3. Build and run (Cmd+R)
4. Grant **Accessibility** permission when prompted (System Settings > Privacy & Security > Accessibility)
5. Click the camera icon in the menu bar and toggle **Enabled**

## Usage

| Action | What happens |
|---|---|
| Press **F13** | Region selection crosshair appears. Select an area. The screenshot is pasted into Claude Desktop and the temp file is trashed. |
| **AirDrop a screenshot** from iPhone | ClawdGrabber detects the new file in ~/Downloads, pastes it into Claude Desktop, and trashes the original. |
| Click **menu bar icon** | Toggle the utility on/off. When off, neither the hotkey nor the Downloads watcher are active. |

## iPhone Screenshot Detection

ClawdGrabber watches `~/Downloads` for new image files matching these patterns:

- `IMG_*.png` / `IMG_*.heic` / `IMG_*.jpg` (iPhone camera roll naming)
- Files containing "Screenshot" in the name with `.png` extension (AirDrop screenshot naming)

Toggle the utility **off** in the menu bar if you need to receive an iPhone screenshot without it being grabbed.

## Architecture

```
ClawdGrabberApp.swift     — App entry point, MenuBarExtra UI
AppDelegate.swift         — Owns all services, wires callbacks
AppState.swift            — Observable toggle state, persisted via UserDefaults
HotkeyManager.swift       — Global F13 hotkey via NSEvent monitor
ScreenshotService.swift   — Invokes macOS screencapture CLI
ClaudePasteService.swift  — Clipboard + activate Claude + simulate Cmd+V
DownloadsWatcher.swift    — DispatchSource file system watcher on ~/Downloads
```

## License

MIT License. See [LICENSE](LICENSE) for details.
