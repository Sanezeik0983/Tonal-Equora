import SwiftUI

extension SessionLedgerDeck {
    func comparison(
        for record: AcousticSessionRecord
    ) -> SessionComparisonSnapshot? {
        guard let previous =
                SessionCompareEngine.previousRecord(
                    for: record,
                    records: memory.sessions
                )
        else {
            return nil
        }

        return SessionCompareEngine.compare(
            current: record,
            previous: previous
        )
    }

    func musicPrimaryValue(
        _ record: MusicAssistRecord
    ) -> String {
        switch record.kind {
        case .roomScan:
            guard let snapshot = record.roomSnapshot else {
                return "—"
            }

            return String(
                format: "%.1f dB",
                snapshot.averageDBFS
            )

        case .speakerMatch:
            guard let match = record.speakerMatch else {
                return "—"
            }

            return String(
                format: "Δ %.1f dB",
                match.absoluteLevelDifferenceDB
            )
        }
    }

    func dayHeader(
        _ date: Date
    ) -> String {
        date.formatted(
            .dateTime
                .month(.abbreviated)
                .day()
                .year()
        )
        .uppercased()
    }

    func timeText(
        _ date: Date
    ) -> String {
        date.formatted(
            date: .omitted,
            time: .shortened
        )
    }

    func scoreColor(
        _ score: Int
    ) -> Color {
        if score >= 85 {
            return RoomSoftPalette.ink
        }

        if score >= 65 {
            return RoomSoftPalette.orange
        }

        return RoomSoftPalette.coral
    }
}
