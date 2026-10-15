import Foundation

enum ChannelTestMode: String, CaseIterable, Identifiable, Hashable {
    case direct
    case reference
    case manual

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .direct:
            return "DIRECT"

        case .reference:
            return "REFERENCE"

        case .manual:
            return "MANUAL"
        }
    }

    var shortDetail: String {
        switch self {
        case .direct:
            return "phone signal"

        case .reference:
            return "external L/R"

        case .manual:
            return "source controls"
        }
    }

    var explanation: String {
        switch self {
        case .direct:
            return "The iPhone plays a 1 kHz cue into LEFT or RIGHT only. Use this when the phone audio output is connected to the system you want to verify."

        case .reference:
            return "Use a known external left/right identification track or test signal. The iPhone stays silent while you check each labeled side."

        case .manual:
            return "Use the source device's balance, mute or channel controls to isolate LEFT and RIGHT yourself. The iPhone stays silent and records your routing result."
        }
    }

    var sessionMode: SessionChannelMode {
        switch self {
        case .direct:
            return .direct

        case .reference:
            return .reference

        case .manual:
            return .manual
        }
    }

    var usesPhoneAudio: Bool {
        self == .direct
    }
}
