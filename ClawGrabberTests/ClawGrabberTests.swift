import Foundation
import Testing
@testable import ClawGrabber

struct AppStateTests {

    @Test func defaultStateIsFalse() {
        UserDefaults.standard.removeObject(forKey: "isEnabled")
        let state = AppState()
        #expect(state.isEnabled == false)
    }

    @Test func togglePersistsToUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "isEnabled")
        let state = AppState()
        state.isEnabled = true
        #expect(UserDefaults.standard.bool(forKey: "isEnabled") == true)
        state.isEnabled = false
        #expect(UserDefaults.standard.bool(forKey: "isEnabled") == false)
    }

    @Test func restoresPersistedState() {
        UserDefaults.standard.set(true, forKey: "isEnabled")
        let state = AppState()
        #expect(state.isEnabled == true)
        UserDefaults.standard.removeObject(forKey: "isEnabled")
    }
}

struct DownloadsWatcherPatternTests {

    let watcher = DownloadsWatcher()

    @Test func matchesIMGPng() {
        #expect(watcher.isIPhoneScreenshot("IMG_1234.PNG") == true)
        #expect(watcher.isIPhoneScreenshot("IMG_1234.png") == true)
    }

    @Test func matchesIMGHeic() {
        #expect(watcher.isIPhoneScreenshot("IMG_0001.HEIC") == true)
        #expect(watcher.isIPhoneScreenshot("IMG_9999.heic") == true)
    }

    @Test func matchesIMGJpeg() {
        #expect(watcher.isIPhoneScreenshot("IMG_5678.JPG") == true)
        #expect(watcher.isIPhoneScreenshot("IMG_5678.jpeg") == true)
    }

    @Test func matchesAirDropScreenshot() {
        #expect(watcher.isIPhoneScreenshot("Screenshot 2026-04-02 at 10.30.00.png") == true)
    }

    @Test func rejectsNonScreenshotFiles() {
        #expect(watcher.isIPhoneScreenshot("document.pdf") == false)
        #expect(watcher.isIPhoneScreenshot("photo.png") == false)
        #expect(watcher.isIPhoneScreenshot("notes.txt") == false)
        #expect(watcher.isIPhoneScreenshot("image_export.png") == false)
    }

    @Test func rejectsPartialMatches() {
        #expect(watcher.isIPhoneScreenshot("MY_IMG_1234.png") == false)
        #expect(watcher.isIPhoneScreenshot("IMG_.png") == true) // prefix match is valid
    }
}

struct HotkeyManagerTests {

    @Test func startAndStopDoNotCrash() {
        let manager = HotkeyManager()
        manager.start()
        manager.stop()
        manager.stop() // double-stop is safe
    }

    @Test func startIsIdempotent() {
        let manager = HotkeyManager()
        manager.start()
        manager.start() // should not create duplicate monitors
        manager.stop()
    }
}

struct DownloadsWatcherLifecycleTests {

    @Test func startAndStopDoNotCrash() {
        let watcher = DownloadsWatcher()
        watcher.start()
        watcher.stop()
        watcher.stop() // double-stop is safe
    }
}
