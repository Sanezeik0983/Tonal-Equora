import Foundation

enum FrequencyTestMode: String, CaseIterable, Identifiable, Hashable {
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
            return "phone tone"

        case .reference:
            return "external tone"

        case .music:
            return "relative analysis"
        }
    }

    var explanation: String {
        switch self {
        case .direct:
            return "The iPhone generates the selected tone through its current audio output. Use this when the phone is connected to the system you want to test."

        case .reference:
            return "Play the selected frequency from your TV, computer, receiver or another source. The iPhone does not generate audio in this mode."

        case .music:
            return "Use normal music and the iPhone microphone for relative tonal comparison in Music Assist. Music mode does not create a technical frequency CAL result."
        }
    }

    var canCreateCalibrationResult: Bool {
        self != .music
    }

    var supportsSweep: Bool {
        self == .direct
    }
}
