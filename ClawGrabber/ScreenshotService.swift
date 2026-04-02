import Foundation

class ScreenshotService {
    func captureRegion(completion: @escaping (URL?) -> Void) {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("clawgrab_\(UUID().uuidString).png")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = ["-i", tempURL.path]
        process.terminationHandler = { proc in
            DispatchQueue.main.async {
                if proc.terminationStatus == 0 &&
                   FileManager.default.fileExists(atPath: tempURL.path) {
                    completion(tempURL)
                } else {
                    completion(nil) // user cancelled
                }
            }
        }
        do {
            try process.run()
        } catch {
            completion(nil)
        }
    }
}
