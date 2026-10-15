import SwiftUI

enum LabInstrument: String, CaseIterable, Identifiable, Codable, Hashable {
    case alignment
    case channels
    case center
    case spatial
    case noise
    case frequency
    case balance

    var id: String { rawValue }

    var title: String {
        switch self {
        case .alignment: "Align"
        case .channels: "L / R"
        case .center: "Center"
        case .spatial: "Spatial"
        case .noise: "Noise"
        case .frequency: "Freq"
        case .balance: "Balance"
        }
    }

    var technicalTitle: String {
        switch self {
        case .alignment: "SPEAKER ALIGNMENT"
        case .channels: "CHANNEL CHECK"
        case .center: "PHANTOM CENTER"
        case .spatial: "STEREO FIELD"
        case .noise: "ROOM NOISE"
        case .frequency: "FREQUENCY SWEEP"
        case .balance: "CHANNEL BALANCE"
        }
    }

    var symbol: String {
        switch self {
        case .alignment: "dot.scope"
        case .channels: "speaker.wave.2"
        case .center: "scope"
        case .spatial: "circle.hexagongrid"
        case .noise: "waveform"
        case .frequency: "waveform.path.ecg"
        case .balance: "slider.horizontal.2.square"
        }
    }

    var tint: Color {
        switch self {
        case .alignment:
            return ClyraPalette.sun
        case .channels:
            return ClyraPalette.orange
        case .center:
            return ClyraPalette.accent
        case .spatial:
            return ClyraPalette.peach
        case .noise:
            return ClyraPalette.amber
        case .frequency:
            return ClyraPalette.coral
        case .balance:
            return ClyraPalette.orange
        }
    }

    var sessionKind: SessionKind {
        switch self {
        case .alignment: .alignment
        case .channels: .channel
        case .center: .center
        case .spatial: .spatial
        case .noise: .noise
        case .frequency: .frequency
        case .balance: .balance
        }
    }
}
