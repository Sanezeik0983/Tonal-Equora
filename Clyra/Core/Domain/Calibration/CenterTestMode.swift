import Foundation

enum CenterTestMode: String, CaseIterable, Identifiable, Hashable {
    case direct
    case reference
    case music

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .direct:
            return "DIRECT"

        case .reference:
            return "REFERENCE"

        case .music:
            return "MUSIC"
        }
    }

    var shortDetail: String {
        switch self {
        case .direct:
            return "phone signal"

        case .reference:
            return "external mono"

        case .music:
            return "centered vocal"
        }
    }

    var explanation: String {
        switch self {
        case .direct:
            return "The iPhone plays the same 700 Hz signal through both channels. Use this when the phone is connected to the system you want to check."

        case .reference:
            return "Play a known mono or center reference through the system's normal source. The iPhone stays silent while you judge where the phantom image appears."

        case .music:
            return "Play a track with a clearly centered vocal or lead element. Keep your head at the listening position and judge where that center image appears."
        }
    }

    var sessionMode: SessionCenterMode {
        switch self {
        case .direct:
            return .direct

        case .reference:
            return .reference

        case .music:
            return .music
        }
    }

    var usesPhoneAudio: Bool {
        self == .direct
    }
}
