import SwiftUI

enum WaveDockRoute: String, CaseIterable, Identifiable {
    case room
    case sessions
    case system

    var id: String { rawValue }

    var title: String {
        switch self {
        case .room:
            return "Room"
        case .sessions:
            return "Sessions"
        case .system:
            return "System"
        }
    }

    var symbol: String {
        switch self {
        case .room:
            return "hifispeaker.2"
        case .sessions:
            return "clock.arrow.circlepath"
        case .system:
            return "slider.horizontal.3"
        }
    }
}
