import UIKit

enum WavePulse {
    private static let hapticsKey = "clyra_haptics_enabled"

    static func light() {
        guard hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func selection() {
        guard hapticsEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    private static var hapticsEnabled: Bool {
        if UserDefaults.standard.object(forKey: hapticsKey) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: hapticsKey)
    }
}
