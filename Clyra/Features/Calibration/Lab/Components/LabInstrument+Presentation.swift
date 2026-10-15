import SwiftUI

extension LabInstrument {
    var usesSoftRetroChrome: Bool {
        switch self {
        case .alignment,
             .channels,
             .center,
             .spatial,
             .noise,
             .frequency,
             .balance:
            return true
        }
    }

    var softRetroHeaderTitle: String {
        switch self {
        case .alignment:
            return "Speaker alignment"

        case .channels:
            return "L / R channel test"

        case .center:
            return "Phantom center"

        case .spatial:
            return "Stereo field"

        case .noise:
            return "Room noise"

        case .frequency:
            return "Frequency sweep"

        case .balance:
            return "Stereo balance"
        }
    }

    var softRetroMeasurementFill: Color {
        switch self {
        case .alignment:
            return RoomSoftPalette.surfaceWarm

        case .channels:
            return RoomSoftPalette.cardCream

        case .center:
            return RoomSoftPalette.cardButter

        case .spatial:
            return RoomSoftPalette.cardSand

        case .noise:
            return RoomSoftPalette.cardCream

        case .frequency:
            return RoomSoftPalette.cardButter

        case .balance:
            return RoomSoftPalette.cardSand
        }
    }
}

extension LabInstrument {
    var headerTag: String {
        switch self {
        case .alignment:
            return "ALIGNMENT"

        case .channels:
            return "CHANNEL TEST"

        case .center:
            return "CENTER IMAGE"

        case .spatial:
            return "STEREO FIELD"

        case .noise:
            return "ROOM NOISE"

        case .frequency:
            return "FREQUENCY"

        case .balance:
            return "BALANCE"
        }
    }

    var headerTitle: String {
        switch self {
        case .alignment:
            return "Speaker geometry"

        case .channels:
            return "L / R channel test"

        case .center:
            return "Phantom image"

        case .spatial:
            return "Stereo field"

        case .noise:
            return "Room noise"

        case .frequency:
            return "Tone generator"

        case .balance:
            return "Stereo balance"
        }
    }
}
