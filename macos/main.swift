import Cocoa
import AVFoundation

class WP: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []
    var loopers: [AVPlayerLooper] = []
    var players: [AVQueuePlayer] = []
    func videoURL(for screen: NSScreen) -> URL {
        let dir = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("LiveWallpaper")
        let w = screen.frame.width * screen.backingScaleFactor
        let big = dir.appendingPathComponent("wallpaper.mp4")
        let small = dir.appendingPathComponent("wallpaper_1080.mp4")
        if w <= 2000, FileManager.default.fileExists(atPath: small.path) { return small }
        return big
    }
    var lastSig = ""
    func log(_ m: String) {
        let line = "\(Date()) \(m)\n"
        let u = URL(fileURLWithPath: "/tmp/livewallpaper.log")
        if let h = try? FileHandle(forWritingTo: u) { h.seekToEndOfFile(); h.write(line.data(using: .utf8)!); h.closeFile() }
        else { try? line.write(to: u, atomically: true, encoding: .utf8) }
    }
    func sig() -> String { NSScreen.screens.map { "\($0.frame)@\($0.backingScaleFactor)" }.joined(separator: "|") }
    func build() {
        lastSig = sig(); log("build \(lastSig)")
        windows.forEach { $0.orderOut(nil) }; windows = []; loopers = []; players.forEach { $0.pause() }; players = []
        for s in NSScreen.screens {
            let win = NSWindow(contentRect: s.frame, styleMask: .borderless, backing: .buffered, defer: false)
            win.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
            win.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            win.ignoresMouseEvents = true
            win.backgroundColor = .black
            win.isOpaque = true
            win.hasShadow = false
            win.animationBehavior = .none
            let dir = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("LiveWallpaper")
            let still = dir.appendingPathComponent(s.frame.width * s.backingScaleFactor <= 2000 ? "still_1920.jpg" : "still_2560.jpg")
            if FileManager.default.fileExists(atPath: still.path) {
                try? NSWorkspace.shared.setDesktopImageURL(still, for: s, options: [.imageScaling: NSImageScaling.scaleProportionallyUpOrDown.rawValue, .allowClipping: true])
            }
            let item = AVPlayerItem(url: videoURL(for: s))
            let p = AVQueuePlayer()
            p.isMuted = true
            p.preventsDisplaySleepDuringVideoPlayback = false
            let looper = AVPlayerLooper(player: p, templateItem: item)
            let v = NSView(frame: s.frame); v.wantsLayer = true
            if let img = NSImage(contentsOf: still) {
                v.layer?.contents = img
                v.layer?.contentsGravity = .resizeAspectFill
            }
            v.layer?.backgroundColor = NSColor(calibratedWhite: 0.75, alpha: 1).cgColor
            let layer = AVPlayerLayer(player: p); layer.videoGravity = .resizeAspectFill
            layer.frame = v.bounds; layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            v.layer?.addSublayer(layer)
            win.contentView = v
            win.setFrame(s.frame, display: true)
            win.orderFrontRegardless()
            p.play()
            windows.append(win); players.append(p); loopers.append(looper)
        }
    }
    func applicationDidFinishLaunching(_ n: Notification) {
        build()
        NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            let n = self.sig(); self.log("screenParams changed=\(n != self.lastSig)")
            if n != self.lastSig { self.build() }
        }
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { [weak self] n in
            let a = (n.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?.localizedName ?? "?"
            self?.log("activate \(a)")
        }
        let wc = NSWorkspace.shared.notificationCenter
        wc.addObserver(forName: NSWorkspace.screensDidSleepNotification, object: nil, queue: .main) { [weak self] _ in self?.players.forEach { $0.pause() } }
        wc.addObserver(forName: NSWorkspace.screensDidWakeNotification, object: nil, queue: .main) { [weak self] _ in self?.players.forEach { $0.play() } }
    }
}
let app = NSApplication.shared
let activity = ProcessInfo.processInfo.beginActivity(options: [.userInitiatedAllowingIdleSystemSleep, .latencyCritical], reason: "live wallpaper")
app.setActivationPolicy(.accessory)
let d = WP(); app.delegate = d
app.run()
