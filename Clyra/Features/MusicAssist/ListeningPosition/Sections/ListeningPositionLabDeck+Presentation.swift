import SwiftUI

extension ListeningPositionLabDeck {
    var resultRecord: MusicListeningPositionRecord? {

        if let savedRecord,
            phase == .complete
        {
            return savedRecord
        }

        guard let positionA,
            let positionB,
            let positionC
        else {
            return nil
        }

        return MusicListeningPositionRecord(
            setupID: setup.id,
            positionA: positionA,
            positionB: positionB,
            positionC: positionC
        )
    }

    var hasCapturedPosition: Bool {
        positionA != nil || positionB != nil || positionC != nil
    }

    var headerSubtitle: String {
        switch phase {
        case .a:
            return "FIRST LISTENING POSITION"

        case .b:
            return "SECOND LISTENING POSITION"

        case .c:
            return "THIRD LISTENING POSITION"

        case .complete:
            return "THREE-POSITION COMPARISON"
        }
    }

    var visualizationStatus: String {
        if analyzer.musicDetected {
            return "MUSIC · DETECTED"
        }

        if analyzer.isRunning {
            return "POSITION \(phase.positionTitle) · LISTENING"
        }

        if phase == .complete {
            return "POSITION MEMORY · COMPLETE"
        }

        return "POSITION \(phase.positionTitle) · READY"
    }

    var captureEyebrow: String {
        switch phase {
        case .a:
            return "CAPTURE POSITION A"

        case .b:
            return "CAPTURE POSITION B"

        case .c:
            return "CAPTURE POSITION C"

        case .complete:
            return "CAPTURE COMPLETE"
        }
    }

    var captureContext: String {
        switch phase {
        case .a:
            return "FIRST POSITION"

        case .b:
            return "SAME MUSIC · B"

        case .c:
            return "SAME MUSIC · C"

        case .complete:
            return savedRecord == nil ? "A / B / C NOT SAVED" : "A / B / C SAVED"
        }
    }

    var captureActionTitle: String {
        analyzer.isRunning
            ? "CANCEL CAPTURE"
            : phase.captureTitle
    }

    var captureActionSymbol: String {
        analyzer.isRunning
            ? "xmark"
            : phase == .complete
                ? "checkmark"
                : "waveform"
    }

    var analyzerStatusTitle: String {
        if analyzer.musicDetected {
            return "MUSIC DETECTED"
        }

        if analyzer.isRunning {
            return "LISTENING"
        }

        if phase == .complete {
            return "COMPLETE"
        }

        return "READY"
    }

    var analyzerStatusTint: Color {
        if analyzer.musicDetected {
            return RoomSoftPalette.orange
        }

        if analyzer.isRunning {
            return RoomSoftPalette.yellow
        }

        if phase == .complete {
            return RoomSoftPalette.orange
        }

        return RoomSoftPalette.lineStrong.opacity(0.60)
    }
}
