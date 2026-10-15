import SwiftUI

extension MusicAssistDeck {
    func loadSavedBaseline() {
        guard
            let previous =
                archive
                .latestRoomScan(
                    for: setup.id
                )?
                .roomSnapshot
        else {
            return
        }

        previousRoomSnapshot = previous
    }

    func consume(_ snapshot: MusicRoomSnapshot) {
        switch mode {
        case .roomScan:
            if roomSnapshot == nil,
                previousRoomSnapshot == nil
            {
                previousRoomSnapshot =
                    archive
                    .latestRoomScan(
                        for: setup.id
                    )?
                    .roomSnapshot
            }

            roomSnapshot = snapshot

            lastSavedAt = nil
            saveCurrentResult()

        case .speakerMatch:
            switch speakerPhase {
            case .left:
                leftSnapshot = snapshot
                speakerPhase = .right

            case .right:
                rightSnapshot = snapshot
                speakerPhase = .complete

                lastSavedAt = nil
                saveCurrentResult()

            case .complete:
                break
            }
        }
    }

    func saveCurrentResult() {
        guard lastSavedAt == nil else { return }
        let record: MusicAssistRecord?
        switch mode {
        case .roomScan:
            guard let roomSnapshot else { return }
            record = archive.saveRoomScan(roomSnapshot, setupID: setup.id)
        case .speakerMatch:
            guard speakerPhase == .complete, let leftSnapshot, let rightSnapshot else { return }
            record = archive.saveSpeakerMatch(
                left: leftSnapshot, right: rightSnapshot, setupID: setup.id)
        }
        lastSavedAt = record?.createdAt
        saveError = record == nil ? archive.storageErrorMessage : nil
    }

    func insightTint(
        _ severity: MusicAssistInsight.Severity
    ) -> Color {
        switch severity {
        case .good:
            return RoomSoftPalette.orange

        case .attention:
            return RoomSoftPalette.coral

        case .neutral:
            return RoomSoftPalette.yellow
        }
    }

    func insightSymbol(
        _ severity: MusicAssistInsight.Severity
    ) -> String {
        switch severity {
        case .good:
            return "checkmark.circle"

        case .attention:
            return "exclamationmark.triangle"

        case .neutral:
            return "waveform.path.ecg"
        }
    }

    func dbfsText(_ value: Double) -> String {
        String(
            format: "%.1f dBFS",
            value
        )
    }

    func signedDB(_ value: Double) -> String {
        if abs(value) < 0.05 {
            return "0.0 dB"
        }

        return String(
            format: "%+.1f dB",
            value
        )
    }

    func signedPercent(_ value: Double) -> String {
        let percent = value * 100

        if abs(percent) < 0.5 {
            return "0%"
        }

        return String(
            format: "%+.0f%%",
            percent
        )
    }
}
