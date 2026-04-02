import Foundation

class DownloadsWatcher {
    private var source: DispatchSourceFileSystemObject?
    private var knownFiles: Set<String> = []
    private let downloadsURL: URL
    var onNewScreenshot: ((URL) -> Void)?

    init() {
        downloadsURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Downloads")
        knownFiles = currentImageFiles()
    }

    func start() {
        // Refresh known files snapshot on start
        knownFiles = currentImageFiles()

        let fd = open(downloadsURL.path, O_EVTONLY)
        guard fd >= 0 else { return }

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd, eventMask: .write, queue: .main)
        source?.setEventHandler { [weak self] in
            self?.checkForNewFiles()
        }
        source?.setCancelHandler {
            close(fd)
        }
        source?.resume()
    }

    func stop() {
        source?.cancel()
        source = nil
    }

    private func checkForNewFiles() {
        let current = currentImageFiles()
        let newFiles = current.subtracting(knownFiles)
        knownFiles = current

        for filename in newFiles {
            if isIPhoneScreenshot(filename) {
                let url = downloadsURL.appendingPathComponent(filename)
                // Delay to ensure file is fully written (AirDrop can be slow)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    // Verify file still exists and has content
                    guard FileManager.default.fileExists(atPath: url.path),
                          let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                          let size = attrs[.size] as? Int, size > 0 else {
                        return
                    }
                    self?.onNewScreenshot?(url)
                }
            }
        }
    }

    private func currentImageFiles() -> Set<String> {
        let contents = (try? FileManager.default.contentsOfDirectory(
            atPath: downloadsURL.path)) ?? []
        return Set(contents.filter { name in
            let lower = name.lowercased()
            return lower.hasSuffix(".png") || lower.hasSuffix(".heic") ||
                   lower.hasSuffix(".jpg") || lower.hasSuffix(".jpeg")
        })
    }

    func isIPhoneScreenshot(_ name: String) -> Bool {
        let lower = name.lowercased()
        // IMG_1234.PNG / IMG_1234.HEIC (iPhone camera roll naming)
        if lower.hasPrefix("img_") &&
           (lower.hasSuffix(".png") || lower.hasSuffix(".heic") ||
            lower.hasSuffix(".jpg") || lower.hasSuffix(".jpeg")) {
            return true
        }
        // "Screenshot 2026-04-02 at 10.30.00.png" (AirDrop screenshot naming)
        if lower.contains("screenshot") && lower.hasSuffix(".png") {
            return true
        }
        return false
    }
}
