import Foundation
import CMultitouch

final class TouchListener {
    static let shared = TouchListener()
    
    var on3FingerTap: (() -> Void)?
    
    private(set) var isEnabled: Bool = true
    
    private init() {}
    
    func start() {
        isEnabled = true
        MTBridgeStartListening {
            DispatchQueue.main.async {
                guard TouchListener.shared.isEnabled else { return }
                print("[3Tap] 3-finger tap detected!")
                TouchListener.shared.on3FingerTap?()
            }
        }
    }
    
    func stop() {
        isEnabled = false
        MTBridgeStopListening()
    }

    func restartAfterWake() {
        guard isEnabled else { return }
        MTBridgeRestartListening()
    }
    
    func toggle() {
        if isEnabled {
            stop()
        } else {
            start()
        }
    }
    
    func setMaxDuration(_ seconds: Double) {
        MTBridgeSetMaxDuration(seconds)
    }
}
