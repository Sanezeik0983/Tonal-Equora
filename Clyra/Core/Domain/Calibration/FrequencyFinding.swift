import SwiftUI

enum FrequencyFinding: String, Codable, CaseIterable, Identifiable, Hashable {
    case clear
    case weak
    case resonance

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .clear:
            return "CLEAR"

        case .weak:
            return "WEAK"

        case .resonance:
            return "RESONANCE"
        }
    }

    var detail: String {
        switch self {
        case .clear:
            return "Even and clean"

        case .weak:
            return "Noticeably reduced"

        case .resonance:
            return "Boost, buzz or rattle"
        }
    }

    var symbol: String {
        switch self {
        case .clear:
            return "checkmark"

        case .weak:
            return "arrow.down"

        case .resonance:
            return "waveform.badge.exclamationmark"
        }
    }

    var score: Int {
        switch self {
        case .clear:
            return 100

        case .weak:
            return 58

        case .resonance:
            return 42
        }
    }

    var tint: Color {
        switch self {
        case .clear:
            return ClyraPalette.sun

        case .weak:
            return ClyraPalette.orange

        case .resonance:
            return ClyraPalette.coral
        }
    }
}
